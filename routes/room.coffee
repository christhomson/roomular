UWapi = require('../lib/api')
nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' });
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

  app.get('/rooms', (req, res) ->
    if req.query.room
      res.redirect '/rooms/' + req.query.room.toUpperCase().replace(' ', '')
    else
      res.redirect '/'
  )

  app.get('/rooms/:room', (req, res) =>
    api = new UWapi(nconf.get('uwaterloo_api_key'))
    api.getCourseFromRoom(req.params.room, (err, classes) =>

      classes = classes.sort (a, b) ->
        parseInt(a.StartTime.split(':')[0], 10) - parseInt(b.StartTime.split(':')[0], 10)

      for day of days
        days[day].classes = _.filter(classes, (clas) ->
          clas.Days.match(days[day].regex)?
        )

      hasClasses = classes.length > 0
      res.render('room', { layout: 'minimal', days: days, hasClasses: hasClasses})
    )
  )