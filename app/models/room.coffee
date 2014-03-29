_ = require('underscore')
nconf = require('nconf')
nconf.argv().env().file({ file: '../../config/local.json' })
UWapi = require('./api')

module.exports = class Room
  constructor: (buildingAndRoom) ->
    buildingAndRoom = buildingAndRoom.split(/\s/).join('')
    roomParts = buildingAndRoom.match(/([A-Za-z]*)([0-9]*)/)
    @building = roomParts[1].toUpperCase()
    @room_number = roomParts[2]

    if @building.length is 1 or @building is 'EV'
      @building += @room[0]
      @room = @room.substring(1)

  @load: (id, cb) ->
    room = new Room(id)
    room.loadClasses(cb)

  loadClasses: (cb) ->
    unless @classes?
      api = new UWapi(nconf.get('uwaterloo_api_key'))
      api.getCourseFromRoom(@building, @room_number, (err, classes) =>
        @classes = @setAdditionalClassAttributes(classes)
        cb(null, @)
      )

  scheduleForDay: (day) ->
    classes = _.filter @classes, (clas) -> clas.weekdays.match(day.regex())?
    classes.sort (a, b) ->
      parseInt(a.start_time.split(':')[0], 10) - parseInt(b.start_time.      split(':')[0], 10)

  setAdditionalClassAttributes: (classes) ->
    classes.map (clas) =>
      # [ 'Nguyen,Trien T' ] => "Trien T Nguyen"
      clas.instructor = clas.instructors?[0]?.split(',')?.reverse()?.join(' '      ) || "Unknown Instructor"
      clas.classType = @determineClassType(clas)

      startTime = clas.start_time.split(':')
      endTime = clas.end_time.split(':')
      hours = endTime[0] - startTime[0]
      minutes = endTime[1] - startTime[1]

      clas.halfHours = (hours * 2) + (Math.ceil(minutes / 30.0))
      clas

  determineClassType: (clas) ->
    # See https://uwaterloo.ca/quest/undergraduate-students/glossary-of-terms.
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

