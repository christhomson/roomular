express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });
exphbs  = require('express3-handlebars')

@app = express()

@app.engine('handlebars', exphbs({defaultLayout: 'main'}))
@app.set('view engine', 'handlebars')

@routes = {
  room_schedule: require('./routes/room_schedule')(@app)
}

@app.listen(process.env.PORT || nconf.get('server').port)