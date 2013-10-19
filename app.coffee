express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' });
exphbs  = require('express3-handlebars')

@app = express()


@app.engine('handlebars', exphbs({
  defaultLayout: 'main'
  helpers: {
    downcase: (str) -> str.toLowerCase()
    upcase: (str) -> str.toUpperCase()
    mixpanelToken: -> nconf.get('mixpanel_token')
  }
}))

@app.set('view engine', 'handlebars')
@app.use(express.static(__dirname + '/public'));

@routes = {
  room: require('./routes/room')(@app)
  index: require('./routes/index')(@app)
}

port = process.env.PORT || nconf.get('server').port
@app.listen(port)
console.log("Roomular started on port #{port}.")