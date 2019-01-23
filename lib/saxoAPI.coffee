moment        = require 'moment'
h             = require './helpers/helpers'
request       = require 'superagent'
requirejs     = require 'requirejs'
EventEmitter2 = require('eventemitter2').EventEmitter2
inflection    = require 'inflection'
io            = require 'socket.io-client'
async         = require 'async'
util          = require 'util'

signalR       = require 'signalr-client'


camelize = (fieldName)  -> inflection.camelize fieldName.toLowerCase(), true

debug    = (data) -> console.log util.inspect data

module.exports = class SaxoAPI extends EventEmitter2
  me:        null
  saxoToken: "eyJhbGciOiJFUzI1NiIsIng1dCI6IkQ2QzA2MDAwMDcxNENDQTI5QkYxQTUyMzhDRUY1NkNENjRBMzExMTcifQ.eyJvYWEiOiI3Nzc3NyIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoiLWY2TW94UktjaHZHY0s4c3x0fGU0Zz09IiwiY2lkIjoiLWY2TW94UktjaHZHY0s4c3x0fGU0Zz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiY2Q0OTNmYjhlYTE3NDBlYjgyZDNmMDA0Y2Q1NTQxYTIiLCJkZ2kiOiI4NCIsImV4cCI6IjE1MjkzNjUzNDUifQ.FY3rd1J45ND7HlVmhZnbnxmQWYPf8x0UwpPSt1S6J9xWUXIifdLWr7VfWSfBF-uMbhEWE2-lxFJ4jndYU3gq9g"

  constructor: (@config) ->
    super()
    @h             = h
    @subscriptions = {}
    @mode          = "dev"

    # @h.debug @config

    # note : in dev world, token expires every 24 hours
    @token = "eyJhbGciOiJFUzI1NiIsIng1dCI6IkQ2QzA2MDAwMDcxNENDQTI5QkYxQTUyMzhDRUY1NkNENjRBMzExMTcifQ.eyJvYWEiOiI3Nzc3NyIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoiLWY2TW94UktjaHZHY0s4c3x0fGU0Zz09IiwiY2lkIjoiLWY2TW94UktjaHZHY0s4c3x0fGU0Zz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiY2Q0OTNmYjhlYTE3NDBlYjgyZDNmMDA0Y2Q1NTQxYTIiLCJkZ2kiOiI4NCIsImV4cCI6IjE1MjkzNjUzNDUifQ.FY3rd1J45ND7HlVmhZnbnxmQWYPf8x0UwpPSt1S6J9xWUXIifdLWr7VfWSfBF-uMbhEWE2-lxFJ4jndYU3gq9g"

    @sessionCookie = []

    # subscriptions       = {}
    # @config.delimiter    ?= ':'
    # @config.maxListeners ?= 100
    # @config.wildcard     ?= on

    # super
    #   delimiter:    @config.delimiter
    #   maxListeners: @config.maxListeners
    #   wildcard:     @config.wildcard
    #   newListener:  no

  authenticationUrl: () ->
    switch @mode
      when "dev"      then @config.saxo.authenticationUrlDev
      when "prod"     then @config.saxo.authenticationUrlProduction
      when "readonly" then @config.saxo.readonlyAuthenticationUrl

  saxoApiUrl: () ->
    switch @mode
      when "dev"      then @config.saxo.openApiBaseUrlDev
      when "prod"     then @config.saxo.openApiBaseUrlProduction
      when "readonly" then @config.saxo.readonlyOpenApiBaseUrl

  socketConnectionUrl: () ->
    switch @mode
      when "dev"      then @config.saxo.streamingUrlDev
      when "prod"     then @config.saxo.streamingUrProduction
      when "readonly" then "Not available"

  socketSubscriptionBaseUrl: () ->
    switch @mode
      when "dev"      then @config.saxo.subscriptionBaseUrlDev
      when "prod"     then @config.saxo.subscriptionBaseUrlProduction
      when "readonly" then "Not available"

  request: (method, uri, data, cookie, cb) ->
    method = method.toUpperCase()

    # req = request method, "#{@config.endpoint}#{uri}"
    req = request method, "#{@saxoApiUrl()}#{uri}"

    console.log "saxoApi: url: #{@saxoApiUrl()}#{uri}"

    req.set 'accept', 'json'
    req.set 'Authorization', "Bearer #{@token}"
    # console.log "#{uri} -->"
    # console.log "cookie: #{cookie}"
    # console.log ""
    req.set 'Cookie', cookie if cookie?

    # @h.debug req
    # @h.debug req.url
    # @h.debug method
    # @h.debug data

    # # req.set 'X-IG-API-KEY', @config.apiKey
    # # req.set 'version', version
    # #
    # # if isIGDeleteBugFix  # Fix for IG DELETE bug
    # #   req.set '_method', "DELETE"
    # #
    # # unless uri is '/session'
    # #   req.set 'X-SECURITY-TOKEN', @securityToken
    #   req.set 'CST', @cst
    #   req.set 'Content-Type', 'application/json; charset=UTF-8'

    req.send data if data? and method is 'PATCH'
    req.send data if data? and method is 'POST'
    req.send data if data? and method is 'PUT'
    req.send data if data? and method is 'DELETE'

    req.end (res) =>
      # if res.ok
      #   @cst = res.header['cst'] if res.header['cst']?
      #   @securityToken = res.header['x-security-token'] if res.header['x-security-token']?
      cb(res)

  get:    (uri, cookie, cb)       -> @request 'get',    uri, null, cookie, cb
  post:   (uri, data, cookie, cb) -> @request 'post',   uri, data, cookie, cb
  put:    (uri, data, cookie, cb) -> @request 'put',    uri, data, cookie, cb
  patch:  (uri, data, cookie, cb) -> @request 'patch',  uri, data, cookie, cb
  delete: (uri, data, cookie, cb) -> @request 'delete', uri, data, cookie, cb

  updateToken: (token) -> @token = token

  queryFromOptions: (options) ->
    query = ""
    for key, value of options
      if query isnt "" then query += "&"
      query += "#{key}=#{value}"
    return query

  handleIsAliveResponse: (service, res, cb) ->
    switch res.headers['set-cookie']?
      when true
        # unless @sessionCookie = "" then separator
        @sessionCookie.push res.headers['set-cookie']
        cb null, @sessionCookie
      when false
        if @sessionCookie? cb "no cookie", null
        else cb null, @sessionCookie

  handleResponse: (res, cb) ->
      switch res.ok and res.body?
        when true  then cb null, res.body
        when false
          switch res.statusCode
            when 400 then cb res.body, null
            when 405 then cb res.body, null
            else cb res.statusCode

  getIsAlive: (service, cb) ->
    @get "/#{service}/isalive", @sessionCookie,  (res) => @handleIsAliveResponse service, res, cb

  getMe: (cb) ->
    @get '/port/v1/users/me',   @sessionCookie,  (res) => @handleResponse res, cb

  getClients: (cb) ->
    @get '/port/v1/clients/me',  @sessionCookie,  (res) => @handleResponse res, cb

  getAccounts: (cb) ->
    @get '/port/v1/accounts/me', @sessionCookie, (res) => @handleResponse res, cb

  getAccountBalance: (clientKey, accountKey, cb) ->
    @get "/port/v1/balances?ClientKey=#{clientKey}&AccountKey=#{accountKey}", @sessionCookie, (res) =>
      @handleResponse res, cb

  getInstruments: (options, cb) ->
    #@get "/ref/v1/instruments?KeyWords=#{keyWords}&AssetTypes=#{assetTypes}", (res) =>
    @get "/ref/v1/instruments/?#{@queryFromOptions options}", @sessionCookie, (res) =>
      @handleResponse res, cb

  getInstrumentDetail: (options, cb) ->
    @get "/ref/v1/instruments/details/?#{@queryFromOptions options}", @sessionCookie, (res) =>
      @handleResponse res, cb

  getInstrumentDetail: (options, cb) ->
    @get "/ref/v1/instruments/details/#{options.Uic}/#{options.AssetType}/?#{@queryFromOptions options}", @sessionCookie, (res) =>
      @handleResponse res, cb

  getPrice: (options, cb) ->
    @get "/trade/v1/infoprices?#{@queryFromOptions options}", @sessionCookie, (res) => @handleResponse res, cb

  getPrices: (options, cb) ->
    @get "/trade/v1/infoprices/list?#{@queryFromOptions options}", @sessionCookie, (res) => @handleResponse res, cb

  getOrders: (options, cb) ->
    @get "/port/v1/orders/me?#{@queryFromOptions options}", @sessionCookie, (res) => @handleResponse res, cb

  postOrder: (options, cb) ->
    @post "/trade/v2/orders", options, @sessionCookie, (res) => @handleResponse res, cb

  patchOrder: (options, cb) ->
    @patch "/trade/v2/orders", options, @sessionCookie, (res) => @handleResponse res, cb

  precheckOrder: (options, cb) ->
    options.FieldGroups = ["Commissions", "MarginImpact"]
    @post "/trade/v2/orders/precheck", options, @sessionCookie, (res) => @handleResponse res, cb

  cancelOrder: (options, cb) ->
    @delete "/trade/v2/orders/#{options.orderIds}/?AccountKey=#{options.AccountKey}", options, @sessionCookie, (res) => @handleResponse res, cb

  getPositions: (options, cb) ->
    @get "/port/v1/positions?#{@queryFromOptions options}", @sessionCookie, (res) => @handleResponse res, cb

  getMessages: (cb) ->
    @get "/trade/v1/messages", @sessionCookie,(res) => @handleResponse res, cb

  # TODO: how to close positions via API..?
  # closePosition: (options, cb) ->
  #   # reverse position direction
  #   # creat new market order
  #
  #   position = options.position
  #   amount   = options.position.PositionBase.Amount
  #
  #   order =
  #     Uic:       position.PositionBase.Uic
  #     BuySell:   if amount > 0 then "Sell" else "Buy"
  #     AssetType: position.PositionBase.AssetType
  #     Amount:    if amount > 0 then amount else -amount # Amount must by > 0
  #     OrderType: "Market"
  #     OrderRelation: "StandAlone"
  #     AccountKey: options.AccountKey
  #   @postOrder order, cb

  #
  # Subscription Api
  #

  ###

  Subscription API seems only to work through SignalR - so not working on node
  ###

  connect: (cb) ->
    unless @token? then return cb new Error "Not logged in"

    contextId = "C#{Date.now()}"

    # @h.debug contextId

    query = "authorization=#{@token}&context=#{contextId}"

    # @h.debug query

    # url = "#{@socketConnectionUrl()}?#{query}"
    #
    # @h.debug url

    @h.debug signalR

    hub = "saxo"

    client = new signalR.client @socketConnectionUrl(), [hub], 10, true
    client.queryString =
      authorization: @token
      context: contextId

    client.on hub, 'addmessage', (name, message) =>
      @h.debug "received: #{name} : #{message}"

    client.serviceHandlers.onUnauthorized = (res) =>
      console.log "websocket unauthorized"

      # location = res.headers.location
      # result   = @get

    @h.debug client

    @h.debug client.url
    @h.debug client.queryString

    client.start()

    # connection = signalR @socketConnectionUrl(), query, true
    # proxy      = connection.createHubProxy 'saxoStreamingService'
    #
    # proxy.on 'message', (message) =>
    #   @h.debug message
    #
    #
    # connection.start()

    # opts =
    #   transports: ['websocket']
    #
    # socket = io url, opts
    #
    # @h.debug socket.id
    #
    # socket.on 'connect', () =>
    #   @h.debug socket.id
    #   @h.debug "SaxoApi streaming service connected"
    #
    # socket.on 'connect-error', (error) =>
    #   @h.debug "SaxoApi streaming service connection error: #{error}"
    #
    # socket.on 'error', (error) =>
    #   @h.debug "SaxoApi streaming service error: #{error}"
    #
    # socket.on 'disconnect', (reason) =>
    #   @h.debug "SaxoApi streaming service disconnected: #{reason}"
