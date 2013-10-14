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
    }
  }

  LATEST_ROOMS = "roomular:rooms:latest"

  gapClassForTimeframe = (startTime, endTime) ->
    startTime[1] = if startTime[1] < 9 then "#{startTime[1]}0" else startTime[1]
    endTime[1] = if endTime[1] < 9 then "#{endTime[1]}0" else endTime[1]

    {
      StartTime: startTime.join(':')
      EndTime: endTime.join(':')
      halfHours: (endTime[0] - startTime[0]) * 2 + (Math.ceil((endTime[1] - startTime[1]) / 30.0))
      isGap: true
    }

  calculateTimeDifference = (startTime, endTime) ->
    (endTime[0] - startTime[0]) * 60 + (endTime[1] - startTime[1])

  getNextWeekDayName = (today) ->
    nextWeekDay = if today > 4 then 1 else today + 1
    day = _.findWhere(days, {dayOfWeek: nextWeekDay}).dayName

  getLastWeekDayName = (today) ->
    lastWeekDay = if today is 1 then 5 else today - 1
    _.findWhere(days, {dayOfWeek: lastWeekDay}).dayName


  app.get('/rooms', (req, res) ->
    if req.query.room
      res.redirect '/rooms/' + req.query.room.toUpperCase().replace(' ', '')
    else
      res.redirect '/'
  )

  # TODO - this code needs some serious refactoring
  app.get('/rooms/:room/:day?*', (req, res) =>
    api = new UWapi(nconf.get('uwaterloo_api_key'))

    dayRequested = switch(req.params.day?.toLowerCase())
      when 'monday',    'm'  then 1
      when 'tuesday',   't'  then 2
      when 'wednesday', 'w'  then 3
      when 'thursday',  'th' then 4
      when 'friday',    'f'  then 5
      else new Date().getDay()
    dayRequested = 1 if dayRequested is 0 or dayRequested > 5

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

        days[day].numberOfGaps = 0

        # Add in gaps.
        previousEndTime = [8, 30]
        _.each(days[day].classes, (clas, i) ->
          startTime = _.map(clas.StartTime.split(':'), (digit) -> parseInt(digit, 10))

          if calculateTimeDifference(previousEndTime, startTime) > 10
            days[day].classes.splice(i, 0, gapClassForTimeframe(previousEndTime, startTime))
            days[day].numberOfGaps++

          previousEndTime = _.map(clas.EndTime.split(':'), (digit) -> parseInt(digit, 10))
        )

        lastClass = days[day].classes[days[day].classes.length - 1]
        lastEndTime = lastClass?.EndTime.split(':').map (digit) -> parseInt(digit, 10)

        if lastClass and calculateTimeDifference(lastEndTime, [22, 0]) > 10
          days[day].classes.push(gapClassForTimeframe(lastEndTime, [22, 0]))
          days[day].numberOfGaps++

      day = _.first(_.filter(days, (d) ->
        d.dayOfWeek is dayRequested
      ))

      day.isToday = (new Date().getDay() is dayRequested) + ""

      day.numberOfClasses = day.classes.length - day.numberOfGaps
      day.hasClasses = day.numberOfClasses > 0

      day.room = req.params.room

      day.nextWeekDay = getNextWeekDayName(day.dayOfWeek)
      day.lastWeekDay = getLastWeekDayName(day.dayOfWeek)

      if day.hasClasses
        process.redis.lpush LATEST_ROOMS, day.room, ->
          process.redis.ltrim LATEST_ROOMS, 0, 9

      res.render('room', day)
    )
  )