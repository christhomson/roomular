UWapi = require('../lib/api')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });

module.exports = (app) ->
  app.get('/room_schedule', (req, res) =>
    api = new UWapi(nconf.get('uwaterloo_api_key'))
    api.getCourseFromRoom(req.query.room, (err, classes) =>

      classes = classes.sort (a, b) ->
        parseInt(a.StartTime.split(':')[0], 10) - parseInt(b.StartTime.split(':')[0], 10)

      res.render('room_schedule', { classes: classes })
    )
  )