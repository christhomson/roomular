express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });
exphbs  = require('express3-handlebars')

@app = express()

@app.engine('handlebars', exphbs({defaultLayout: 'main'}))
@app.set('view engine', 'handlebars')
@app.use(express.static(__dirname + '/public'));

@routes = {
  room: require('./routes/room')(@app)
  index: require('./routes/index')(@app)
}

@app.listen(process.env.PORT || nconf.get('server').port)