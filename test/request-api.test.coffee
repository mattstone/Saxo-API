should  = require('chai').should()
SaxoAPI = require '..'
util    = require "util"
async   = require 'async'

saxo    = new SaxoAPI require '../config/config'

## Begin tests

clientKey         = null
defaultAccountId  = null
defaultAccountKey = null
defaultAccount    = null

masterOrder       = {}
testOrder         = {}
positions         = null

Uic               = 2047
Instrument        = null
Price             = null
AssetTypes        = null
OrderId           = null
Contracts         = null

stopOrder         = null
toOpenOrder       = null
profitOrder       = null

aaplUic           = null

isExecuted        = no

validRelatedCFDOrder      = null
validRelatedCurrencyOrder = null

AAPLCurrentPrice = 157.74

sleep = (time) =>
  new Promise((resolve) =>
    setTimeout resolve, time
  )


debug = (data) ->
  console.log util.inspect data

describe 'Request API', ->

  ###

  Get token from https://www.developer.saxo/

  Not from read only web site.

  ###



  it 'should login', (done) ->
    saxo.config.should.exist
    saxo.updateToken "*** your token here ***"
    done()

  it 'should get me', (done) ->
    saxo.getMe (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.ClientKey.should.be.a 'string'
      data.LegalAssetTypes.should.be.an 'array'
      data.UserId.should.be.a 'string'
      data.UserKey.should.be.a 'string'
      done()

  it 'should get clients', (done) ->
    saxo.getClients (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.ClientId.should.be.a  'string'
      data.ClientKey.should.be.a 'string'
      data.DefaultAccountId.should.be.a  'string'
      data.DefaultAccountKey.should.be.a 'string'
      data.DefaultCurrency.should.be.a   'string'
      data.IsMarginTradingAllowed.should.be.a       'boolean'
      data.IsVariationMarginEligible.should.be.a    'boolean'
      data.LegalAssetTypesAreIndicative.should.be.a 'boolean'

      clientKey         = data.ClientKey
      defaultAccountId  = data.DefaultAccountId
      defaultAccountKey = data.DefaultAccountKey
      done()

  it 'should get getAccounts', (done) ->
    saxo.getAccounts (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      for element in data.Data
        element.AccountGroupKey.should.be.a  'string'
        element.AccountId.should.be.a   'string'
        element.AccountKey.should.be.a  'string'
        element.AccountType.should.be.a 'string'
        element.Active.should.be.a      'boolean'
        element.ClientId.should.be.a    'string'
        element.ClientKey.should.be.a   'string'
        element.SupportsAccountValueProtectionLimit.should.be.a 'boolean'

        if element.AccountKey is defaultAccountKey
          defaultAccount = element

      defaultAccount.should.be.an 'object'
      done()


  it 'should get getAccountBalance for clientKey and defaultAccountKey', (done) ->
    saxo.getAccountBalance clientKey, defaultAccountKey, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.CashBalance.should.be.a 'number'
      data.ClosedPositionsCount.should.be.a 'number'
      data.CollateralCreditValue.should.be.an 'object'
      data.CostToClosePositions.should.be.a 'number'
      data.Currency.should.be.a 'string'
      data.CurrencyDecimals.should.be.a 'number'
      data.IsPortfolioMarginModelSimple.should.be.a 'boolean'
      data.MarginAvailableForTrading.should.be.a 'number'

      # MarginCollateralNotAvailable: 0,
      # MarginExposureCoveragePct: 0,
      # MarginNetExposure: 0,
      # MarginUsedByCurrentPositions: 0,
      # MarginUtilizationPct: 0,
      # NetEquityForMargin: 100000,
      # NetPositionsCount: 0,
      # NonMarginPositionsValue: 0,
      data.OpenPositionsCount.should.be.a 'number'
      # OptionPremiumsMarketValue: 0,
      data.OrdersCount.should.be.a 'number'
      # OtherCollateral: 0,
      # TotalValue: 100000,
      # TransactionsNotBooked: 0,
      # UnrealizedMarginClosedProfitLoss: 0,
      # UnrealizedMarginOpenProfitLoss: 0,
      # UnrealizedMarginProfitLoss: 0,
      # UnrealizedPositionsValue: 0 }
      done()

  it 'should get getInstruments for keyWords DKK and AssetTypes FxSpot', (done) ->
    options =
      keyWords:  "DKK"
      assetTypes: "FxSpot"
    saxo.getInstruments options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      for element in data.Data
        element.AssetType.should.equal  'FxSpot'
        element.Description.should.be.a 'string'
        element.ExchangeId.should.be.a  'string'
        element.GroupId.should.be.a     'number'
        element.Identifier.should.be.a  'number'
        element.SummaryType.should.be.a 'string'
        element.Symbol.should.be.a      'string'
      done()

  it 'should get getInstrumentDetail for Uic 2047', (done) ->
    options =
      Uic:       Uic
      AssetType: "FxSpot"

    saxo.getInstrumentDetail options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.AssetType.should.equal options.AssetType
      data.Uic.should.equal options.Uic
      data.CurrencyCode.should.be.a 'string'
      data.DefaultAmount.should.be.a 'number'
      data.DefaultSlippage.should.be.a 'number'
      data.DefaultSlippageType.should.be.a 'string'
      data.Description.should.be.a 'string'
      data.Exchange.should.be.an 'object'
      data.Format.should.be.an 'object'
      data.FxForwardMaxForwardDate.should.be.a 'string'
      data.FxForwardMinForwardDate.should.be.a 'string'
      data.GroupId.should.be.a 'number'
      data.IncrementSize.should.be.a 'number'
      data.IsTradable.should.be.an 'boolean'
      data.StandardAmounts.should.be.an 'array'
      data.SupportedOrderTypes.should.be.an 'array'
      data.Symbol.should.be.a 'string'
      data.TickSize.should.be.a 'number'
      data.TickSizeLimitOrder.should.be.a 'number'
      data.TickSizeStopOrder.should.be.a 'number'
      data.TradableAs.should.be.an 'array'
      data.TradableOn.should.be.an 'array'
      done()

  it 'should get getPrices for one instrument: 2047', (done) ->
    uic       = 2047
    assetType = "FxSpot"

    options =
      AccountKey: defaultAccountKey
      AssetType: assetType
      Uic: uic

    saxo.getPrice options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Uic.should.equal uic
      data.AssetType.should.equal assetType
      data.LastUpdated.should.be.a  'string'
      data.PriceSource.should.be.a  'string'
      data.Quote.should.be.an       'object'
      data.Quote.Amount.should.be.a 'number'
      data.Quote.Bid.should.be.a    'number'
      data.Quote.Ask.should.be.a    'number'
      data.Quote.DelayedByMinutes.should.be.a 'number'
      done()

  it 'should get getPrices for multiple instruments: 2047,1311,2046,17749,16', (done) ->
    uics       = "2047,1311,2046,17749,16"
    assetType = "FxSpot"

    options =
      AccountKey: defaultAccountKey
      Uics: uics
      AssetType: assetType
      FieldGroups: "DisplayAndFormat"
      Quote: ""

    saxo.getPrices options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'
      data.Data.length.should.equal 5

      for element in data.Data
        element.Uic.should.be.a       'number'
        element.AssetType.should.equal assetType

        element.DisplayAndFormat.Currency.should.be.a      'string'
        element.DisplayAndFormat.Decimals.should.be.a      'number'
        element.DisplayAndFormat.Description.should.be.a   'string'
        element.DisplayAndFormat.Format.should.be.a        'string'
        element.DisplayAndFormat.OrderDecimals.should.be.a 'number'
        element.DisplayAndFormat.Symbol.should.be.a        'string'

        element.LastUpdated.should.be.a 'string'
        element.PriceSource.should.be.a 'string'

        element.Quote.should.be.an       'object'
        element.Quote.Amount.should.be.a 'number'
        element.Quote.Ask.should.be.a    'number'
        element.Quote.Bid.should.be.a    'number'
        element.Quote.DelayedByMinutes.should.be.a 'number'
        element.Quote.ErrorCode.should.be.a    'string'
        element.Quote.Mid.should.be.a          'number'
        element.Quote.PriceTypeAsk.should.be.a 'string'
        element.Quote.PriceTypeBid.should.be.a 'string'
      done()

  it 'should post new order buy Uic 16 @ 7', (done) ->
    Uic = 16
    testOrder =
      Uic:     Uic
      BuySell: "Buy"
      AssetType: "FxSpot"
      OrderPrice: 7
      Amount: 100000
      OrderType: "Limit"
      OrderRelation: "StandAlone"
      OrderDuration:
        DurationType: "GoodTillCancel"
      AccountKey: defaultAccountKey

    saxo.postOrder testOrder, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.OrderId.should.be.a 'string'
      masterOrder = data
      done()

  it 'should list orders', (done) ->
    options =
      fieldGroups: "DisplayAndFormat"

    saxo.getOrders options, (err, data) ->
      should.not.exist err
      should.exist data
      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      isTestOrderFound = no

      for element in data.Data
        element.AccountId.should.be.a 'string'
        element.AccountKey.should.equal defaultAccountKey
        element.Amount.should.be.a 'number'
        element.AssetType.should.be.a 'string'
        element.BuySell.should.be.a 'string'
        element.CalculationReliability.should.be.a 'string'
        element.ClientKey.should.be.a 'string'
        element.CorrelationKey.should.be.a 'string'

        if element.AssetType isnt "CfdOnStock"
          element.CurrentPrice.should.be.a 'number'
          element.CurrentPriceDelayMinutes.should.be.a 'number'
          element.CurrentPriceType.should.be.a 'string'
          element.DistanceToMarket.should.be.a 'number'
          element.MarketPrice.should.be.a 'number'
          element.Price.should.be.a 'number'

        element.OpenOrderType.should.be.a 'string'
        element.DisplayAndFormat.should.be.an 'object'
        element.Duration.should.be.an 'object'
        element.OrderAmountType.should.be.a 'string'
        element.OrderId.should.be.a 'string'
        element.OrderRelation.should.be.a 'string'
        element.OrderTime.should.be.a 'string'
        element.RelatedOpenOrders.should.be.an 'array'
        element.Status.should.be.a 'string'
        element.Uic.should.be.a 'number'

        if element.OrderId is masterOrder.OrderId
          isTestOrderFound = yes
          element.Amount.should.equal    testOrder.Amount
          element.AssetType.should.equal testOrder.AssetType
          element.BuySell.should.equal   testOrder.BuySell
          element.BuySell.should.equal   testOrder.BuySell
          element.OpenOrderType.should.equal testOrder.OrderType
          element.Price.should.equal     testOrder.OrderPrice
          element.Status.should.equal    'Working'
          element.Uic.should.equal       testOrder.Uic

      isTestOrderFound.should.equal yes

      done()

  it "should amend order", (done) ->

    options =
      AssetType: "FxSpot"
      Amount: 1000
      OrderId: masterOrder.OrderId
      OrderType: "Market"
      OrderDuration:
        DurationType: "GoodTillCancel"
      AccountKey: defaultAccountKey

    saxo.patchOrder options, (err, data) ->
      should.not.exist err
      should.exist data
      data.should.be.an 'object'
      data.OrderId.should.equal masterOrder.OrderId
      done()

  it "should cancel order just placed", (done) ->
    options =
      orderImds: masterOrder.OrderId
      AccountKey: defaultAccountKey

    saxo.cancelOrder options, (err, data) ->

      if err?
        isExecuted = yes
      else
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].should.be.an 'object'
        data.Orders[0].OrderId.should.equal masterOrder.OrderId
      done()


  it "should list positions", (done) ->

    options =
      ClientKey: defaultAccountKey
      FieldGroups: "DisplayAndFormat, PositionBase,PositionView"
      AccountKey: defaultAccountKey

    saxo.getPositions options, (err, data) ->
      should.not.exist err
      should.exist data
      data.should.be.an 'object'

      data.__count.should.be.a 'number'
      data.Data.should.be.an 'array'

      for element in data.Data
        element.DisplayAndFormat.should.be.an 'object'
        element.DisplayAndFormat.Currency.should.be.a 'string'
        element.DisplayAndFormat.Decimals.should.be.a 'number'
        element.DisplayAndFormat.Description.should.be.a 'string'
        element.DisplayAndFormat.Format.should.be.a 'string'
        element.DisplayAndFormat.Symbol.should.be.a 'string'

        element.NetPositionId.should.be.a 'string'

        element.PositionBase.should.be.an 'object'
        element.PositionBase.AccountId.should.be.a 'string'
        element.PositionBase.Amount.should.be.a 'number'
        element.PositionBase.AssetType.should.be.a 'string'
        element.PositionBase.CanBeClosed.should.be.a 'boolean'
        element.PositionBase.ClientId.should.be.a 'string'
        element.PositionBase.CloseConversionRateSettled.should.be.a 'boolean'
        element.PositionBase.CorrelationKey.should.be.a 'string'
        element.PositionBase.ExecutionTimeOpen.should.be.a 'string'
        element.PositionBase.OpenPrice.should.be.a 'number'
        element.PositionBase.RelatedOpenOrders.should.be.an 'array'
        element.PositionBase.SourceOrderId.should.be.a 'string'

        if element.PositionBase.SpotDate?
          element.PositionBase.SpotDate.should.be.a 'string'

        element.PositionBase.Status.should.be.a 'string'
        element.PositionBase.Uic.should.be.a 'number'
        element.PositionBase.ValueDate.should.be.a 'string'

        element.PositionId.should.be.a 'string'
        element.PositionView.should.be.an 'object'
        element.PositionView.CalculationReliability.should.be.a 'string'

        if element.PositionView.CalculationReliability is 'Ok'
          element.PositionView.ConversionRateCurrent.should.be.a 'number'
          element.PositionView.ConversionRateOpen.should.be.a 'number'
          element.PositionView.CurrentPrice.should.be.a 'number'
          element.PositionView.CurrentPriceDelayMinutes.should.be.a 'number'
          element.PositionView.CurrentPriceType.should.be.a 'string'
          element.PositionView.Exposure.should.be.a 'number'
          element.PositionView.ExposureCurrency.should.be.a 'string'
          element.PositionView.ExposureInBaseCurrency.should.be.a 'number'
          element.PositionView.InstrumentPriceDayPercentChange.should.be.a 'number'
          element.PositionView.ProfitLossOnTrade.should.be.a 'number'
          element.PositionView.ProfitLossOnTradeInBaseCurrency.should.be.a 'number'
          element.PositionView.TradeCostsTotal.should.be.a 'number'
          element.PositionView.TradeCostsTotalInBaseCurrency.should.be.a 'number'

      positions = data.Data
      done()

   it "should close positions for Uic: 16", (done) =>
     amount = 0

     async.eachSeries positions, (p, cb) =>

       if p.DisplayAndFormat.Symbol is "EURDKK" and p.PositionBase.Status is "Open"
         amount += p.PositionBase.Amount
       cb()
     , (err) ->

       order =
         Uic:       positions[0].PositionBase.Uic
         BuySell:   if amount > 0 then "Sell" else "Buy"
         AssetType: positions[0].PositionBase.AssetType
         Amount:    if amount > 0 then amount else -amount # Amount must by > 0
         OrderType: "Market"
         OrderRelation: "StandAlone"
         AccountKey: defaultAccountKey

       saxo.postOrder order, (err, data) =>
         should.not.exist err
         should.exist data

         data.OrderId.should.be.a 'string'
         done()

  it "should list top level instruments", (done) ->
    AssetTypes = "FxSpot,CfdOnIndex,CfdOnStock,Stock,StockIndex"

    options =
      AssetTypes: AssetTypes
      AccountKey: defaultAccountKey
    saxo.getInstruments options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      for element in data.Data
        element.AssetType.should.be.a   'string'
        element.Description.should.be.a 'string'
        element.ExchangeId.should.be.a  'string'
        element.GroupId.should.be.a     'number'
        element.Identifier.should.be.a  'number'
        element.SummaryType.should.be.a 'string'
        element.Symbol.should.be.a      'string'
        element.TradableAs.should.be.an 'array'
      done()

  it "should search instruments - AUD", (done) ->
    # AssetTypes = "FxSpot,CfdOnIndex,CfdOnStock,Stock,StockIndex"
    AssetTypes = "FxSpot"
    search     = "AUD"

    options =
      Keywords: search
      AssetTypes: AssetTypes
      AccountKey: defaultAccountKey

    saxo.getInstruments options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      for element in data.Data
        if element.IsKeywordMatch?
          element.IsKeywordMatch.should.equal true
        element.Symbol.should.be.a 'string'
        element.Symbol.includes(search).should.equal true
      done()

describe 'Placing Trades - Limit CFD - AAPL', ->
  it "should search instruments for CfdOnStock: AAPL", (done) ->
    # AssetTypes = "FxSpot,CfdOnIndex,CfdOnStock,Stock,StockIndex"
    AssetTypes = "CfdOnStock"
    search     = "AAPL"

    options =
      Keywords: search
      AssetTypes: AssetTypes
      AccountKey: defaultAccountKey

    saxo.getInstruments options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      data.Data.length.should.equal 1

      element = data.Data[0]
      element.should.be.an 'object'
      element.AssetType.should.equal AssetTypes
      element.Symbol.should.be.a 'string'
      element.Identifier.should.be.a 'number'

      aaplUic = element.Identifier
      Uic     = element.Identifier
      done()

  it "should get instrument for CfdOnStock: AAPL", (done) ->
    options =
      Uic:       Uic
      AssetType: AssetTypes

    saxo.getInstrumentDetail options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.AssetType.should.equal AssetTypes
      data.Uic.should.equal Uic
      Instrument = data
      done()

  it "should get price for CfdOnStock: AAPL", (done) ->

    # Note: Saxo does not provide CFD pricing via API

    options =
      AccountKey: defaultAccountKey
      AssetType: AssetTypes
      Uic: Uic

    saxo.getPrice options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      Price = data
      done()
#
  it "should not place order for zero contracts and zero price for CfdOnStock: AAPL", (done) ->
    order =
      Uic: Uic
      BuySell: "Buy"
      AssetType: AssetTypes
      OrderPrice: 0
      Amount: 0
      OrderType: "Limit"
      OrderRelation: "StandAlone"
      OrderDuration:
        DurationType: "GoodTillCancel"
      AccountKey: defaultAccountKey

    saxo.postOrder order, (err, data) ->
      should.not.exist data
      should.exist err

      err.should.be.an 'object'
      err.Message.should.be.a 'string'
      err.ErrorCode.should.be.a 'string'
      err.ModelState.should.be.an 'object'
      err.ModelState.Amount.should.be.an 'array'
      err.ModelState.Amount[0].should.be.a 'string'
      err.ModelState.OrderPrice.should.be.an 'array'
      err.ModelState.OrderPrice[0].should.be.a 'string'
      done()

  it "should not place order for zero contracts for CfdOnStock: AAPL", (done) ->

    order =
      Uic: Uic
      BuySell: "Buy"
      AssetType: AssetTypes
      OrderPrice: 180
      Amount: 0
      OrderType: "Limit"
      OrderRelation: "StandAlone"
      OrderDuration:
        DurationType: "GoodTillCancel"
      AccountKey: defaultAccountKey

    saxo.postOrder order, (err, data) ->
      should.not.exist data
      should.exist err

      err.should.be.an 'object'
      err.Message.should.be.a 'string'
      err.ErrorCode.should.be.a 'string'

      err.ModelState.should.be.an 'object'
      err.ModelState.Amount.should.be.an 'array'
      err.ModelState.Amount[0].should.be.a 'string'
      done()

  it "seems can place order for less than minimum contract size.. should place order for 1 contracts for CfdOnStock: AAPL", (done) ->

    isExecuted = no

    order =
      Uic: Uic
      BuySell: "Buy"
      AssetType: AssetTypes
      OrderPrice: 180
      Amount: 1
      OrderType: "Limit"
      OrderRelation: "StandAlone"
      OrderDuration:
        DurationType: "GoodTillCancel"
      AccountKey: defaultAccountKey

    saxo.postOrder order, (err, data) ->

      if !err?
        isExecuted = yes
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.OrderId.should.be.a 'string'
        OrderId = data.OrderId
      done()

  it "should cancel order just placed", (done) ->
    if isExecuted is no
      done()
    else
      options =
        orderIds: OrderId
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].should.be.an 'object'
        data.Orders[0].OrderId.should.equal OrderId
        done()

describe 'Placing Trades - Market CFD - AAPL', ->

    it "should not place order for zero contracts for CfdOnStock: AAPL", (done) ->

      order =
        Uic: Uic
        BuySell: "Buy"
        AssetType: AssetTypes
        Amount: 0
        OrderType: "Market"
        OrderRelation: "StandAlone"
        AccountKey: defaultAccountKey

      saxo.postOrder order, (err, data) ->
        should.not.exist data
        should.exist err

        err.should.be.an 'object'
        err.Message.should.be.a 'string'
        err.ErrorCode.should.be.a 'string'
        err.ModelState.should.be.an 'object'
        err.ModelState.Amount.should.be.an 'array'
        err.ModelState.Amount[0].should.be.an 'string'
        done()

    it "should place order for 1 contract for CfdOnStock: AAPL", (done) ->

      order =
        Uic: Uic
        BuySell: "Buy"
        AssetType: AssetTypes
        Amount: 1
        OrderType: "Market"
        OrderRelation: "StandAlone"
        AccountKey: defaultAccountKey

      saxo.postOrder order, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.OrderId.should.be.a 'string'
        OrderId = data.OrderId
        done()

    it "should cancel order just placed", (done) ->
      options =
        orderIds: OrderId
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].should.be.an 'object'
        data.Orders[0].OrderId.should.equal OrderId
        done()

  describe 'Placing Trades - Limit with Stop and Target CFD - AAPL', ->

    it "should not place order limit, stop & target for zero contracts for CfdOnStock: AAPL", (done) ->
      Contracts   = 0
      entryPrice  = AAPLCurrentPrice - 5
      stopPrice   = AAPLCurrentPrice - 40
      targetPrice = AAPLCurrentPrice + 40
      accountKey  = defaultAccountKey # should be client

      stopOrder =
        Uic: Uic
        BuySell: "Sell"
        AssetType: AssetTypes
        OrderPrice: stopPrice
        Amount: Contracts
        OrderType: "StopIfOffered"
        OrderDuration:
          DurationType: "GoodTillCancel"
        ToOpenClose: "ToClose"
        AccountKey: accountKey

      profitOrder =
        Uic: Uic
        BuySell: "Sell"
        AssetType: AssetTypes
        OrderPrice: targetPrice
        Amount: Contracts
        OrderType: "Limit"
        OrderDuration:
          DurationType: "GoodTillCancel"
        ToOpenClose: "ToClose"
        AccountKey: accountKey

      toOpenOrder =
        Uic: Uic
        BuySell: "Buy"
        AssetType: AssetTypes
        OrderPrice: entryPrice
        Amount: Contracts
        OrderType: "Limit"
        OrderDuration:
          DurationType: "GoodTillCancel"
        ToOpenClose: "ToOpen"
        PlaceRelatedOrOcoOrder: [stopOrder, profitOrder]
        AccountKey: accountKey

      saxo.postOrder toOpenOrder, (err, data) ->
        should.not.exist data
        should.exist err
        done()

    it "should place order limit, stop & target for 10 contracts for CfdOnStock: AAPL", (done) ->
      Contracts   = 10

      stopOrder.Amount   = Contracts
      profitOrder.Amount = Contracts
      toOpenOrder.Amount = Contracts
      toOpenOrder.PlaceRelatedOrOcoOrder = [stopOrder, profitOrder]

      saxo.postOrder toOpenOrder, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.OrderId.should.be.a 'string'
        OrderId = data.OrderId
        done()

    it "should cancel order just placed", (done) ->
      options =
        orderIds: OrderId
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].should.be.an 'object'
        data.Orders[0].OrderId.should.equal OrderId
        done()

describe 'Placing Trades - Limit with Stop and Target FXSpot - 16', ->

    it "should not place order limit, stop & target for zero Amount for EURDKK", (done) ->
      Uic         = 16
      AssetTypes  = "FxSpot"
      Contracts   = 0
      entryPrice  = 7.0
      stopPrice   = 6.0
      targetPrice = 8.0
      accountKey  = defaultAccountKey # should be client

      stopOrder =
        Uic: Uic
        BuySell: "Sell"
        AssetType: AssetTypes
        OrderPrice: stopPrice
        Amount: Contracts
        OrderType: "StopIfOffered"
        OrderDuration:
          DurationType: "GoodTillCancel"
        ToOpenClose: "ToClose"
        AccountKey: accountKey

      profitOrder =
        Uic: Uic
        BuySell: "Sell"
        AssetType: AssetTypes
        OrderPrice: targetPrice
        Amount: Contracts
        OrderType: "Limit"
        OrderDuration:
          DurationType: "GoodTillCancel"
        ToOpenClose: "ToClose"
        AccountKey: accountKey

      toOpenOrder =
        Uic: Uic
        BuySell: "Buy"
        AssetType: AssetTypes
        OrderPrice: entryPrice
        Amount: Contracts
        OrderType: "Limit"
        OrderDuration:
          DurationType: "GoodTillCancel"
        ToOpenClose: "ToOpen"
        PlaceRelatedOrOcoOrder: [stopOrder, profitOrder]
        AccountKey: accountKey

      saxo.postOrder toOpenOrder, (err, data) ->
        should.not.exist data
        should.exist err
        done()

    it "should place order limit, stop & target for amount 10000 for FxSpot: EURDKK", (done) ->
      Contracts   = 10000

      stopOrder.Amount   = Contracts
      profitOrder.Amount = Contracts
      toOpenOrder.Amount = Contracts
      toOpenOrder.PlaceRelatedOrOcoOrder = [stopOrder, profitOrder]

      saxo.postOrder toOpenOrder, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.OrderId.should.be.a 'string'
        OrderId = data.OrderId
        done()

    it "should cancel order just placed", (done) ->
      options =
        orderIds: OrderId
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].should.be.an 'object'
        data.Orders[0].OrderId.should.equal OrderId
        done()

    it "should not place order market, stop & target for zero Amount for EURDKK", (done) ->
      Uic         = 16
      AssetTypes  = "FxSpot"
      Contracts   = 0
      entryPrice  = 7.0
      stopPrice   = 6.0
      targetPrice = 8.0
      accountKey  = defaultAccountKey # should be client

      stopOrder =
        # Uic: Uic
        BuySell: "Sell"
        # AssetType: AssetTypes
        OrderPrice: stopPrice
        # Amount: amount
        OrderType: "StopIfOffered"
        OrderDuration:
          DurationType: "GoodTillCancel"
        # ToOpenClose: "ToClose"
        # AccountKey: accountKey

      profitOrder =
        # Uic: Uic
        BuySell: "Sell"
        # AssetType: AssetTypes
        OrderPrice: targetPrice
        # Amount: amount
        OrderType: "Limit"
        OrderDuration:
          DurationType: "GoodTillCancel"
        # ToOpenClose: "ToClose"
        # AccountKey: accountKey

      toOpenOrder =
        Uic: Uic
        BuySell: "Buy"
        AssetType: AssetTypes
        Amount: Contracts
        OrderType: "Market"
        # ToOpenClose: "ToOpen"
        Orders: [stopOrder, profitOrder]
        AccountKey: accountKey

      saxo.postOrder toOpenOrder, (err, data) ->
        should.not.exist data
        should.exist err

        err.should.be.an 'object'
        err.Message.should.be.a 'string'
        err.ModelState.should.be.an 'object'
        err.ModelState.Amount.should.be.an 'array'
        err.ErrorCode.should.be.a 'string'
        done()


    it "should place order market, stop for amount 4000 for FxSpot: EURDKK", (done) ->
      Contracts = 4000

      toOpenOrder.Amount = Contracts
      toOpenOrder.Orders = [stopOrder]

      validRelatedCurrencyOrder = toOpenOrder

      saxo.postOrder toOpenOrder, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.OrderId.should.be.a 'string'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].OrderId.should.be.a 'string'
        testOrder   = data
        masterOrder = data
        done()

    # it "should add target to order", (done) ->
    #   profitOrder.Uic       = Uic
    #   profitOrder.AssetType = AssetTypes
    #   profitOrder.Amount    = Contracts
    #
    #   addProfitToOrder =
    #     # OrderId: testOrder.OrderId
    #     OrderId: masterOrder.Orders[0].OrderId
    #     Orders: [profitOrder]
    #
    #   saxo.patchOrder addProfitToOrder, (err, data) ->
    #
    #     # should.not.exist err
    #     # should.exist data
    #
    #     # data.should.be.an 'object'
    #     # data.OrderId.should.be.a 'string'
    #     # data.Orders.should.be.an 'array'
    #     # data.Orders.length.should.equal 1
    #     # data.Orders[0].OrderId.should.be.a 'string'
    #     # testOrder = data
    #     done()

    # it "should cancel positionToClose.PositionBase.RelatedOpenOrders ", (done) ->
    #
    #   for order in positionToClose.PositionBase.RelatedOpenOrders
    #     options =
    #       orderIds: order.OrderId # close last order..
    #       AccountKey: defaultAccountKey
    #
    #     saxo.cancelOrder options, (err, data) ->
    #       should.not.exist err
    #       should.exist data
    #       data.should.be.an 'object'
    #       done()

    it "should close stop loss order for position just placed", (done) ->

      options =
        orderIds: testOrder.Orders[0].OrderId
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        done()

    it "should close position just placed", (done) ->

      closePosition =
        Uic: Uic
        BuySell: "Sell"
        AssetType: AssetTypes
        Amount: 4000
        OrderType: "Market"
        OrderRelation: "StandAlone"
        AccountKey: defaultAccountKey

      saxo.postOrder closePosition, (err, data) ->
        should.not.exist err
        data.should.exist
        data.should.be.an 'object'
        done()

    it "should precheck order", (done) ->
      preCheck =
        Uic:        Uic
        AssetType:  AssetTypes
        Amount:     Contracts
        BuySell:    "Buy"
        OrderType:  "Market"
        AccountKey: defaultAccountKey

      saxo.precheckOrder preCheck, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.Commissions.should.be.an 'object'
        data.Commissions.CommissionCurrency.should.be.an 'string'
        data.Commissions.CostBuy.should.be.an 'number'
        data.EstimatedCashRequired.should.be.a 'number'
        data.EstimatedCashRequiredCurrency.should.be.a 'string'
        data.MarginImpact.should.be.an 'object'
        data.MarginImpact.ImpactBuy.should.be.a 'number'
        data.MarginImpact.MarginImpactCurrency.should.be.a 'string'
        data.PreCheckResult.should.equal 'Ok'
        done()

describe 'Placing Trades - Related CFD - AAPL', ->

    it "should place related order for AAPL @ market price + 2: #{AAPLCurrentPrice + 2}", (done) ->
      Uic        = aaplUic
      AssetTypes = "CfdOnStock"
      Contracts     = 2

      testOrder =
        Uic:        Uic
        AssetType:  AssetTypes
        Amount:     Contracts
        BuySell:    "Buy"
        OrderType:  "Limit"
        OrderPrice: AAPLCurrentPrice + 2
        AccountKey: defaultAccountKey
        OrderDuration:
          DurationType: "GoodTillCancel"

      profitTargetOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "Limit"
        AssetType:  AssetTypes
        Amount:     Contracts
        OrderPrice: AAPLCurrentPrice + 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      stopOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "StopIfTraded"
        AssetType:  AssetTypes
        Amount:     Contracts
        OrderPrice:  AAPLCurrentPrice - 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      testOrder.orders     = [profitTargetOrder, stopOrder]
      validRelatedCFDOrder = testOrder

      saxo.postOrder testOrder, (err, data) ->
        should.not.exist err
        data.should.exist

        data.should.be.an 'object'
        data.OrderId.should.be.a 'string'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 2

        for order in data.Orders
          order.OrderId.should.be.a 'string'
        masterOrder = data
        done()

    it 'should list orders', (done) ->
      options =
        fieldGroups: "DisplayAndFormat"

      saxo.getOrders options, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.Data.should.be.an 'array'
        data.Data.length.should.equal 1

        order = data.Data[0]

        order.Uic.should.equal        testOrder.Uic
        order.AssetType.should.equal  testOrder.AssetType
        order.Amount.should.equal     testOrder.Amount
        order.BuySell.should.equal    testOrder.BuySell
        order.Price.should.equal      testOrder.OrderPrice
        order.Status.should.equal     'Working'
        order.Duration.DurationType.should.equal testOrder.OrderDuration.DurationType

        order.OrderRelation.should.equal 'IfDoneMaster'
        order.RelatedOpenOrders.should.be.an 'array'
        order.RelatedOpenOrders.length.should.equal 2

        # testOrder.orders = [profitTargetOrder, stopOrder]
        profitOrder = null
        stopOrder   = null

        for element in order.RelatedOpenOrders
          if element.OrderId is masterOrder.Orders[0].OrderId then profitOrder = element
          if element.OrderId is masterOrder.Orders[1].OrderId then stopOrder   = element

        profitOrder.should.not.equal null
        stopOrder.should.not.equal   null

        profitOrder.Amount.should.equal        testOrder.orders[0].Amount
        profitOrder.OpenOrderType.should.equal testOrder.orders[0].OrderType
        profitOrder.OrderPrice.should.equal    testOrder.orders[0].OrderPrice
        profitOrder.Duration.DurationType.should.equal testOrder.orders[0].OrderDuration.DurationType

        stopOrder.Amount.should.equal        testOrder.orders[1].Amount
        stopOrder.OpenOrderType.should.equal testOrder.orders[1].OrderType
        stopOrder.OrderPrice.should.equal    testOrder.orders[1].OrderPrice
        stopOrder.Duration.DurationType.should.equal testOrder.orders[1].OrderDuration.DurationType
        done()

    it "should amend main order", (done) ->
      testOrder.OrderPrice = AAPLCurrentPrice + 3

      order =
        AccountKey: defaultAccountKey
        AssetType:  testOrder.AssetType
        OrderId:    masterOrder.OrderId
        OrderPrice: testOrder.OrderPrice
        OrderType:  testOrder.OrderType
        OrderDuration:
          DurationType: testOrder.OrderDuration.DurationType

      saxo.patchOrder order, (err, data) ->
        should.not.exist err
        data.should.be.an 'object'
        data.OrderId.should.equal masterOrder.OrderId
        done()

    it 'should see price change in master order', (done) ->
      options =
        fieldGroups: "DisplayAndFormat"

      saxo.getOrders options, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.Data.should.be.an 'array'
        data.Data.length.should.equal 1
        data.Data[0].should.be.an 'object'

        order = data.Data[0]
        order.OrderId.should.equal masterOrder.OrderId
        order.Price.should.equal   testOrder.OrderPrice
        done()

    it "should amend profit target for related order", (done) ->

      testOrder.orders[0].OrderPrice = testOrder.orders[0].OrderPrice + 3

      profitTargetOrder = testOrder.orders[0]

      order =
        AccountKey: defaultAccountKey
        AssetType:  profitTargetOrder.AssetType
        OrderId:    masterOrder.Orders[0].OrderId
        OrderPrice: profitTargetOrder.OrderPrice
        OrderType:  profitTargetOrder.OrderType
        OrderDuration:
          DurationType: profitTargetOrder.OrderDuration.DurationType

      saxo.patchOrder order, (err, data) ->
        should.not.exist err
        data.should.be.an 'object'
        data.OrderId.should.equal masterOrder.Orders[0].OrderId
        done()

    it 'should see price change in related profit target order', (done) ->
      options =
        fieldGroups: "DisplayAndFormat"

      saxo.getOrders options, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.Data.should.be.an 'array'
        data.Data.length.should.equal 1
        data.Data[0].should.be.an 'object'
        order = data.Data[0]

        profitTargetOrder = null
        for element in order.RelatedOpenOrders
          if element.OrderId is masterOrder.Orders[0].OrderId then profitTargetOrder = element

        profitTargetOrder.should.be.an 'object'
        profitTargetOrder.OrderPrice.should.equal testOrder.orders[0].OrderPrice
        done()

    it "should amend stop loss for related order", (done) ->
      testOrder.orders[1].OrderPrice = testOrder.orders[1].OrderPrice - 3

      stopLossOrder = testOrder.orders[1]

      order =
        AccountKey: defaultAccountKey
        AssetType:  stopLossOrder.AssetType
        OrderId:    masterOrder.Orders[1].OrderId
        OrderPrice: stopLossOrder.OrderPrice
        OrderType:  stopLossOrder.OrderType
        OrderDuration:
          DurationType: stopLossOrder.OrderDuration.DurationType

      saxo.patchOrder order, (err, data) ->
        should.not.exist err
        data.should.be.an 'object'
        data.OrderId.should.equal masterOrder.Orders[1].OrderId
        done()

    it 'should see price change in related stop loss order', (done) ->
      options =
        fieldGroups: "DisplayAndFormat"

      saxo.getOrders options, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.Data.should.be.an 'array'
        data.Data.length.should.equal 1
        data.Data[0].should.be.an 'object'
        order = data.Data[0]

        stopLossOrder = null
        for element in order.RelatedOpenOrders
          if element.OrderId is masterOrder.Orders[1].OrderId then stopLossOrder = element

        stopLossOrder.should.be.an 'object'
        stopLossOrder.OrderPrice.should.equal testOrder.orders[1].OrderPrice
        done()

    it "should amend order price, target and stop in one request", (done) ->
      testOrder.OrderPrice = testOrder.OrderPrice + 1
      testOrder.orders[0].OrderPrice = testOrder.orders[0].OrderPrice + 1
      testOrder.orders[1].OrderPrice = testOrder.orders[1].OrderPrice - 1

      order =
        AccountKey: defaultAccountKey
        AssetType:  testOrder.AssetType
        OrderId:    masterOrder.OrderId
        OrderPrice: testOrder.OrderPrice
        OrderType:  testOrder.OrderType
        OrderDuration:
          DurationType: testOrder.OrderDuration.DurationType

      profitTargetOrder =
        AccountKey: defaultAccountKey
        AssetType:  testOrder.orders[0].AssetType
        OrderId:    masterOrder.Orders[0].OrderId
        OrderPrice: testOrder.orders[0].OrderPrice
        OrderType:  testOrder.orders[0].OrderType
        OrderDuration:
          DurationType: testOrder.orders[0].OrderDuration.DurationType

      stopLossOrder =
        AccountKey: defaultAccountKey
        AssetType:  testOrder.orders[1].AssetType
        OrderId:    masterOrder.Orders[1].OrderId
        OrderPrice: testOrder.orders[1].OrderPrice
        OrderType:  testOrder.orders[1].OrderType
        OrderDuration:
          DurationType: testOrder.orders[1].OrderDuration.DurationType

      order.Orders = [profitTargetOrder, stopLossOrder]

      saxo.patchOrder order, (err, data) ->
        should.not.exist err
        data.should.be.an 'object'

        data.OrderId.should.equal masterOrder.OrderId
        data.Orders[0].OrderId.should.equal masterOrder.Orders[0].OrderId
        data.Orders[1].OrderId.should.equal masterOrder.Orders[1].OrderId
        done()

    it 'should see all price changes', (done) ->
      options =
        fieldGroups: "DisplayAndFormat"

      saxo.getOrders options, (err, data) ->
        should.not.exist err
        should.exist data

        data.should.be.an 'object'
        data.Data.should.be.an 'array'
        data.Data.length.should.equal 1
        data.Data[0].should.be.an 'object'
        order = data.Data[0]

        order.OrderId.should.equal masterOrder.OrderId
        order.Price.should.equal   testOrder.OrderPrice

        profitTargetOrder = null
        stopLossOrder     = null
        for element in order.RelatedOpenOrders
          if element.OrderId is masterOrder.Orders[0].OrderId then profitTargetOrder = element
          if element.OrderId is masterOrder.Orders[1].OrderId then stopLossOrder     = element

        profitTargetOrder.should.be.an 'object'
        stopLossOrder.should.be.an     'object'
        profitTargetOrder.OrderPrice.should.equal testOrder.orders[0].OrderPrice
        stopLossOrder.OrderPrice.should.equal     testOrder.orders[1].OrderPrice
        done()

    it "should cancel order just placed", (done) ->

      options =
        orderIds: masterOrder.OrderId
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->

        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        data.Orders.should.be.an 'array'
        data.Orders.length.should.equal 1
        data.Orders[0].should.be.an 'object'
        data.Orders[0].OrderId.should.equal masterOrder.OrderId
        done()
#
    it "should not place combined order with an error in the master order", (done) ->
      Uic        = aaplUic
      AssetTypes = "CfdOnStock"
      Contracts     = 2

      testOrder =
        Uic:        Uic
        AssetType:  AssetTypes
        Amount:     Contracts
        BuySell:    "Buy"
        OrderType:  "Limit"
        # OrderPrice: AAPLCurrentPrice + 2
        AccountKey: defaultAccountKey
        OrderDuration:
          DurationType: "GoodTillCancel"

      profitTargetOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "Limit"
        AssetType:  AssetTypes
        Amount:     Contracts
        OrderPrice: AAPLCurrentPrice + 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      stopOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "StopIfTraded"
        AssetType:  AssetTypes
        Amount:     Contracts
        OrderPrice:  AAPLCurrentPrice - 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      testOrder.orders = [profitTargetOrder, stopOrder]

      saxo.postOrder testOrder, (err, data) ->
        should.not.exist data
        err.should.exist
        done()

    it "should not place combined order with an error in the profit target order", (done) ->
      Uic        = aaplUic
      AssetTypes = "CfdOnStock"
      Contracts     = 2

      testOrder =
        Uic:        Uic
        AssetType:  AssetTypes
        Amount:     Contracts
        BuySell:    "Buy"
        OrderType:  "Limit"
        OrderPrice: AAPLCurrentPrice + 2
        AccountKey: defaultAccountKey
        OrderDuration:
          DurationType: "GoodTillCancel"

      profitTargetOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "Limit"
        AssetType:  AssetTypes
        Amount:     Contracts
        # OrderPrice: AAPLCurrentPrice + 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      stopOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "StopIfTraded"
        AssetType:  AssetTypes
        Amount:     Contracts
        OrderPrice:  AAPLCurrentPrice - 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      testOrder.orders = [profitTargetOrder, stopOrder]

      saxo.postOrder testOrder, (err, data) ->
        should.not.exist data
        err.should.exist
        done()


    it "should not place combined order with an error in the stop loss order", (done) ->
      Uic        = aaplUic
      AssetTypes = "CfdOnStock"
      Contracts     = 2

      testOrder =
        Uic:        Uic
        AssetType:  AssetTypes
        Amount:     Contracts
        BuySell:    "Buy"
        OrderType:  "Limit"
        OrderPrice: AAPLCurrentPrice + 2
        AccountKey: defaultAccountKey
        OrderDuration:
          DurationType: "GoodTillCancel"

      profitTargetOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "Limit"
        AssetType:  AssetTypes
        Amount:     Contracts
        OrderPrice: AAPLCurrentPrice + 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      stopOrder =
        Uic:        Uic
        BuySell:    "Sell"
        OrderType:  "StopIfTraded"
        AssetType:  AssetTypes
        Amount:     Contracts
        # OrderPrice:  AAPLCurrentPrice - 4
        OrderDuration:
          DurationType: "GoodTillCancel"

      testOrder.orders = [profitTargetOrder, stopOrder]

      saxo.postOrder testOrder, (err, data) ->
        should.not.exist data
        err.should.exist
        done()

describe 'It should edit orders and positions', ->

  cfdOrders       = null
  currencyOrders  = null
  positionToClose = null

  it 'should place limit with stop and target CFD order for AAPL', (done) ->

    saxo.postOrder validRelatedCFDOrder, (err, data) ->
      should.not.exist err
      data.should.exist
      data.should.be.an 'object'

      cfdOrders = data
      done()

  # if order is in orders list then it has not been executed or cancelled
  it 'should list orders and show cfdOrders', (done) ->
    options =
      fieldGroups: "DisplayAndFormat"

    saxo.getOrders options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      data.Data.length.should.equal 1
      data.Data[0].OrderId.should.equal cfdOrders.OrderId
      done()


  # using currency as market is open during our business hours and will get excuted
  it 'place market order with stop and target CFD for Uic: 16 : EURDKK', (done) ->
    validRelatedCurrencyOrder.Amount = 8000

    saxo.postOrder validRelatedCurrencyOrder, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      currencyOrders = data
      done()

  # if currencyOrders.OrderId is not found, then it has become a position
  it 'should list orders and show currencyOrders', (done) ->
    options =
      fieldGroups: "DisplayAndFormat"

    saxo.getOrders options, (err, data) ->
      should.not.exist err
      should.exist data

      data.should.be.an 'object'
      data.Data.should.be.an 'array'

      isFound = no
      for element in data.Data

        if element.OrderId is currencyOrders.OrderId
          isFound = yes

      isFound.should.equal no
      done()

  it 'should list positions', (done) ->
    options =
      fieldGroups: "DisplayAndFormat, PositionBase"
      clientKey: clientKey

    saxo.getPositions options, (err, data) ->
      should.not.exist err
      should.exist data
      data.Data.should.be.an 'array'

      foundPositionFromOrderId = no

      positionToClose = null
      for element in data.Data
        if element.PositionBase.SourceOrderId is currencyOrders.OrderId
          positionToClose = element
          break # found our man.. so exit loop

      positionToClose.should.not.equal null
      positionToClose.PositionBase.RelatedOpenOrders.should.be.an 'array'
      done()

  ###

  NOTE:

  Related orders do not get cancelled when a position is closed.

  So close these first

  Then close positions

  To close position - take equal opposing transaction

  If unable to close - suggest the user try directly in Saxo platform

  ###

  it "should cancel cfdOrders ", (done) ->
    options =
      orderIds: cfdOrders.OrderId # close last order..
      AccountKey: defaultAccountKey

    saxo.cancelOrder options, (err, data) ->
      should.not.exist err
      should.exist data
      data.should.be.an 'object'
      done()

  it "should cancel positionToClose.PositionBase.RelatedOpenOrders ", (done) ->

    for order in positionToClose.PositionBase.RelatedOpenOrders
      options =
        orderIds: order.OrderId # close last order..
        AccountKey: defaultAccountKey

      saxo.cancelOrder options, (err, data) ->
        should.not.exist err
        should.exist data
        data.should.be.an 'object'
        done()

  it "should close position at market", (done) ->
    openPosition = positionToClose.PositionBase

    closePosition =
      Uic:       openPosition.Uic
      AssetType: openPosition.AssetType
      Amount:    openPosition.Amount
      OrderType: "Market"
      OrderRelation: "StandAlone"
      AccountKey: defaultAccountKey

    switch openPosition.Amount > 0
      when true then closePosition.BuySell  = "Sell"
      when false then closePosition.BuySell = "Buy"

    saxo.postOrder closePosition, (err, data) ->
      should.not.exist err
      should.exist.data
      data.should.be.an 'object'
      done()

describe 'Read Only API', ->

  it "should be in read only mode", (done) ->
      saxo.mode = "readonly"
      saxo.mode.should.equal "readonly"
      done()
