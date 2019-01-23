util     = require 'util'
h        = require './helpers/helpers'
AppSpine = require 'appspine'
app      = new AppSpine require('./helpers/helpers').getConfig()
async    = require 'async'

request  = require 'request'

# console.log "I am alive!"


app.init require('./initializers')(app), ->
  start = Date.now()
  debug = app.h.debug

  app.h.debug app.config.saxo.token

  #SAML Authentication Request
  saml = "<samlp:AuthnRequest ID=\"_a04fb772-b9bf-4779-96d8-48843c9d3695\" Version=\"2.0\" IssueInstant=\"2015-07-02T13:41:59Z\" Destination=\"http://www.logonvalidation.net/AuthnRequest\"  ForceAuthn=\"false\"  IsPassive=\"false\"
 ProtocolBinding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" AssertionConsumerServiceURL=\"https://www.logonvalidation.net/MyTestApp\" xmlns:samlp=\"urn:oasis:names:tc:SAML:2.0:protocol\"> <saml:Issuer xmlns:saml=\"urn:oasis:names:tc:SAML:2.0:assertion\">https://www.logonvalidation.net/MyTestApp</saml:Issuer> <samlp:NameIDPolicy AllowCreate=\"false\" /></samlp:AuthnRequest>"

  # app.h.debug saml
  #
  # app.h.debug ""

  token = app.config.saxo.token

  opts =
    url: "https://gateway.saxobank.com/sim/openapi/port/v1/users/me"
    # "Content-Type" : 'application/x-www-form-urlencoded'
    json: yes
    headers:
      "Authorization": "Bearer #{token}"

  # app.h.debug opts

  request.get opts, (error, response, body) ->
    debug response.statusCode
    if error?
      debug error
    else
      debug body
