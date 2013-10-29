UWapi = require('../lib/api')
nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' });
_ = require('underscore')

module.exports = (app) ->
  days = {
    "M": { index: 1, dayName: "Monday", classes: [], regex: /M/ }
    "T": { index: 2, dayName: "Tuesday", classes: [], regex: /(T$|T[^h])/ }
    "W": { index: 3, dayName: "Wednesday", classes: [], regex: /W/ }
    "Th": { index: 4, dayName: "Thursday", classes: [], regex: /Th/ }
    "F": { index: 5, dayName: "Friday", classes: [], regex: /F/ }
  }

  gapClassForTimeframe = (startTime, endTime) ->
    # Pad timestamps, if necessary, for consistency w/ API data
    startTime[0] = if startTime[0] <= 9 then "0#{startTime[0]}" else startTime[0]
    endTime[0] = if endTime[0] <= 9 then "0#{endTime[0]}" else endTime[0]
    startTime[1] = if startTime[1] < 9 then "#{startTime[1]}0" else startTime[1]
    endTime[1] = if endTime[1] < 9 then "#{endTime[1]}0" else endTime[1]

    {
      start_time: startTime.join(':')
      end_time: endTime.join(':')
      halfHours: (endTime[0] - startTime[0]) * 2 + (Math.ceil((endTime[1] - startTime[1]) / 30.0))
      isGap: true
    }

  calculateTimeDifference = (startTime, endTime) ->
    (endTime[0] - startTime[0]) * 60 + (endTime[1] - startTime[1])

  getNextWeekDayName = (today) ->
    nextWeekDay = if today > 4 then 1 else today + 1
    day = _.findWhere(days, {index: nextWeekDay}).dayName

  getLastWeekDayName = (today) ->
    lastWeekDay = if today is 1 then 5 else today - 1
    _.findWhere(days, {index: lastWeekDay}).dayName

  determineClassType = (clas) ->
    switch(clas.section.split(' ')[0])
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

  app.get('/rooms', (req, res) ->
    if req.query.room
      # Split into building and room.
      req.query.room = req.query.room.split(/\s/).join('')
      roomParts = req.query.room.match(/([A-Za-z]*)([0-9]*)/)
      building = roomParts[1].toLowerCase()
      room = roomParts[2]

      if building.length is 1 or building.toUpperCase() is 'EV'
        building += room[0]
        room = room.substring(1)

      if building and room
        res.redirect "/rooms/#{building}/#{room}"
      else
        res.redirect '/'
    else
      res.redirect '/'
  )

  # This function is in massive need of refactoring. It's so damn long.
  app.get('/rooms/:building/:room/:day?*', (req, res) =>
    api = new UWapi(nconf.get('uwaterloo_api_key'))

    req.params.day = req.params.day?[0].toUpperCase() + req.params.day?.substring(1)
    dayRequested = days[req.params.day]?.index || _.findWhere(days, {dayName: req.params.day})?.index || new Date().getDay()
    dayRequested = 1 if dayRequested is 0 or dayRequested > 5

    api.getCourseFromRoom(req.params.building, req.params.room, (err, classes) =>
      classes = classes.sort (a, b) ->
        parseInt(a.start_time.split(':')[0], 10) - parseInt(b.start_time.split(':')[0], 10)

      _.each(classes, (c) ->
        startTime = c.start_time.split(':')
        endTime = c.end_time.split(':')
        hours = endTime[0] - startTime[0]
        minutes = endTime[1] - startTime[1]
        c.halfHours = (hours * 2) + (Math.ceil(minutes / 30.0))
        c.instructor = c.instructors?[0]?.split(',')?.reverse()?.join(' ') || "Unknown Instructor"

        # See https://uwaterloo.ca/quest/undergraduate-students/glossary-of-terms.
        c.classType = determineClassType(c)
      )

      for day of days
        days[day].classes = _.filter(classes, (clas) ->
          clas.weekdays.match(days[day].regex)?
        )

        days[day].numberOfGaps = 0

        # Add in gaps.
        previousEndTime = [8, 30]
        _.each(_.clone(days[day].classes), (clas, i) ->
          startTime = _.map(clas.start_time.split(':'), (digit) -> parseInt(digit, 10))

          if calculateTimeDifference(previousEndTime, startTime) > 10
            days[day].classes.splice(i + days[day].numberOfGaps, 0, gapClassForTimeframe(previousEndTime, startTime))
            days[day].numberOfGaps++

          previousEndTime = _.map(clas.end_time.split(':'), (digit) -> parseInt(digit, 10))
        )

        lastClass = days[day].classes[days[day].classes.length - 1]
        lastEndTime = lastClass?.end_time.split(':').map (digit) -> parseInt(digit, 10)

        if lastClass and calculateTimeDifference(lastEndTime, [22, 0]) > 10
          days[day].classes.push(gapClassForTimeframe(lastEndTime, [22, 0]))
          days[day].numberOfGaps++

      day = _.first(_.filter(days, (d) ->
        d.index is dayRequested
      ))

      day.isToday = (new Date().getDay() is dayRequested) + ""

      day.numberOfClasses = day.classes.length - day.numberOfGaps
      day.hasClasses = day.classes?.length > 0
      day.building = req.params.building
      day.room = req.params.room

      day.nextWeekDay = getNextWeekDayName(day.index)
      day.lastWeekDay = getLastWeekDayName(day.index)

      res.render('room', day)
    )
  )