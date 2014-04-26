hbs = require 'express-hbs'
nconf = require 'nconf'
nconf.argv().env().file({ file: '../../config/local.json' })

module.exports = ->
  hbs.registerHelper 'downcase', (str) -> str.toLowerCase()

  hbs.registerHelper 'upcase', (str) -> str.toUpperCase()

  hbs.registerHelper 'mixpanelToken', -> nconf.get('mixpanel_token')
