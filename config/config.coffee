
path = require 'path'
fs = require 'fs'

module.exports =

  redis:
    host: "127.0.0.1"
    port: 6379
    db: 0

  saxo:
    appKey:    "getFromSaxo"
    appSecret: "getFromSaxo"
    appUrlLocal: "https://localhost:3000/index"
    appUrlDev: "https://localhost:3000/index"
    appUrlProduction: "https://localhost:3000/index"
    authenticationUrlDev:        "https://sim.logonvalidation.net"
    authenticationUrlProduction: "https://sim.logonvalidation.net"
    openApiBaseUrlDev:           "https://gateway.saxobank.com/sim/openapi"
    openApiBaseUrlProduction:    "https://gateway.saxobank.com/sim/openapi"

    streamingUrlDev:             "https://streaming.saxotrader.com/sim/openapi/streaming/connection"
    streamingUrProduction:       "https://streaming.saxotrader.com/openapi/streaming/connection"
    subscriptionBaseUrlDev:      "https://gateway.saxobank.com/sim/openapi/"
    subscriptionBaseUrlProduction: "https://gateway.saxobank.com/openapi/"

    isAliveChartPath: "/openapi/chart/"
    isAliveCsPath:    "/openapi/cs"
    isAlivePortPath:  "/openapi/port"
    isAliveRootPath:  "/openapi/root"
    isAliveStreamingPath: "/openapi/streaming"
    isAliveTradePath: "/openapi/trade"
    isAliveVasPath:   "/openapi/vas"
