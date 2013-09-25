UWapi = require('../lib/api')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });

module.exports = (app) ->
  app.get('/empty_rooms', (req, res) ->
    api = new UWapi(nconf.get('uwaterloo_api_key'))
    api.getCourseFromRoom(req.query.room, (err, courses) ->
      res.send(courses)
    )
  )