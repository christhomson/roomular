express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });

@app = express()
@app.listen(process.env.PORT || nconf.get('server').port)