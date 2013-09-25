express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });

@app = express()

@routes = {
  empty_rooms: require('./routes/empty_rooms')(@app)
}

@app.listen(process.env.PORT || nconf.get('server').port)