UWapi = require('../lib/api')
nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' });
_ = require('underscore')

module.exports = (app) ->
  days = {
    "M": {
      dayOfWeek: 1
      dayName: "Monday"
      classes: []
      regex: /M/
    },
    "T": {
      dayOfWeek: 2
      dayName: "Tuesday"
      classes: []
      regex: /(T$|T[^h])/
    },
    "W": {
      dayOfWeek: 3
      dayName: "Wednesday"
      classes: []
      regex: /W/
    },
    "Th": {
      dayOfWeek: 4
      dayName: "Thursday"
      classes: []
      regex: /Th/
    },
    "F": {
      dayOfWeek: 5
      dayName: "Friday"
      classes: []
      regex: /F/
    },
    "S": {
      dayOfWeek: 6
      dayName: "Saturday"
      classes: []
      regex: /Saturday/ # should never happen
    },
    "Su": {
      dayOfWeek: 7
      dayName: "Sunday"
      classes: []
      regex: /Sunday/ # should never happen
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

      _.each(classes, (c) ->
        startTime = c.StartTime.split(':')
        endTime = c.EndTime.split(':')
        hours = endTime[0] - startTime[0]
        minutes = endTime[1] - startTime[1]
        c.halfHours = (hours * 2) + (Math.ceil(minutes / 30.0))
        c.Instructor = c.Instructor.split(',').reverse().join(' ') || "Unknown Instructor"

        # See https://uwaterloo.ca/quest/undergraduate-students/glossary-of-terms.
        c.classType = switch(c.Section.split(' ')[0])
          when 'CLN' then 'Clinic'
          when 'DIS' then 'Discussion'
          when 'ENS' then 'Ensemble'
          when 'ESS' then 'Essay'
          when 'FLD' then 'Field Studies'
          when 'LAB' then 'Lab'
          when 'LEC' then 'Lecture'
          when 'ORL' then 'Oral Conversation'
          when 'PRA' then 'Practicum'
          when 'PRJ' then 'Project'
          when 'RDG' then 'Reading'
          when 'SEM' then 'Seminar'
          when 'STU' then 'Studio'
          when 'TLC' then 'Test Slot - Lecture'
          when 'TST' then 'Test Slot'
          when 'TUT' then 'Tutorial'
          when 'WRK' then 'Work Term'
          when 'WSP' then 'Workshop'
          else 'Meeting'
      )

      for day of days
        days[day].classes = _.filter(classes, (clas) ->
          clas.Days.match(days[day].regex)?
        )

      day = _.first(_.filter(days, (d) ->
        d.dayOfWeek is new Date().getDay()
      ))

      day.hasClasses = day.classes?.length > 0
      day.room = req.params.room

      res.render('room', day)
    )
  )