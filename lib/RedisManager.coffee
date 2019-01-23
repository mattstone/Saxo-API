redis = require 'redis'
helpers = require './helpers/helpers'
ms = require 'ms'
# type = helpers.type
util = require 'util'
EventEmitter = require('events').EventEmitter


module.exports = class RedisManager extends EventEmitter
  constructor: (@app) ->
    @r = @createClient()
    @app.config.redis.db
    @r.select @app.config.redis.db
    @pub = @createClient()
    @sub = @createClient()

  createClient: ->
    redis.createClient() # @config.port, @config.host

  # # Examples - do not delete
  # getEOD: (symbol, cb) ->
  #   @r.get "eod::#{symbol}", (err, data) ->
  #     cb err, JSON.parse data
  #
  # setEOD: (symbol, object, cb) ->
  #   key = "eod::#{symbol}"
  #   @r.set key, JSON.stringify(object), (err, result) ->
  #     cb err, result
  #
  # deleteEOD: (symbol, cb) ->
  #   key = "eod::#{symbol}"
  #   @r.del key, cb
