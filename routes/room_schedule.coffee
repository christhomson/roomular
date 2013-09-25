UWapi = require('../lib/api')
nconf = require('nconf')
nconf.argv().env().file({ file: 'local.json' });
_ = require('underscore')

module.exports = (app) ->
  days = {
    "M": {
      dayName: "Monday"
      classes: []
      regex: /M/
    },
    "T": {
      dayName: "Tuesday"
      classes: []
      regex: /(T$|T[^h])/
    },
    "W": {
      dayName: "Wednesday"
      classes: []
      regex: /W/
    },
    "Th": {
      dayName: "Thursday"
      classes: []
      regex: /Th/
    },
    "F": {
      dayName: "Friday"
      classes: []
      regex: /F/
    }
  }

  app.get('/room_schedule', (req, res) =>
    api = new UWapi(nconf.get('uwaterloo_api_key'))
    api.getCourseFromRoom(req.query.room, (err, classes) =>

      classes = classes.sort (a, b) ->
        parseInt(a.StartTime.split(':')[0], 10) - parseInt(b.StartTime.split(':')[0], 10)

      for day of days
        days[day].classes = _.filter(classes, (clas) ->
          clas.Days.match(days[day].regex)?
        )

      res.render('room_schedule', { days: days })
    )
  )