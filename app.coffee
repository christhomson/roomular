express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' })
exphbs  = require('express3-handlebars')
Resource = require('express-resource')

@app = express()

@app.engine('handlebars', exphbs({
  defaultLayout: 'application'
  helpers: {
    downcase: (str) -> str.toLowerCase()
    upcase: (str) -> str.toUpperCase()
    mixpanelToken: -> nconf.get('mixpanel_token')
  }
}))

@app.set('view engine', 'handlebars')
@app.use(express.static(__dirname + '/public'))
@app.resource('rooms', require('./app/controllers/rooms'))

port = process.env.PORT || nconf.get('server').port
@app.listen(port)
console.log("Roomular started on port #{port}.")
