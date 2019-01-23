h      = require './helpers/helpers'
util   = require 'util'

module.exports = (app) ->

  Redis: (done) ->
    RedisManager = require './RedisManager'
    app.r = new RedisManager app
    done()

  Helpers: (done) ->
    app.h  = require "./helpers/helpers"
    done()

  # UpdateSymbol: (done) ->
  #   options =
  #     symbol: "SPY"
  #     dataSource: app.h.DataSource.alphavantage
  #   app.dm.newSymbol options, (err, data) ->
  #     h.logDebug err
  #     h.logDebug data
