_ = require('underscore')
nconf = require('nconf')
nconf.argv().env().file({ file: '../../config/local.json' })
UWapi = require('./api')
ClassMeeting = require('./class_meeting')
Schedule = require('./schedule')

module.exports = class Room
  constructor: (buildingAndRoom) ->
    buildingAndRoom = buildingAndRoom.split(/\s/).join('')
    roomParts = buildingAndRoom.match(/([A-Za-z]*)([0-9]*)/)
    @building = roomParts[1].toUpperCase()
    @room_number = roomParts[2]

    if @building.length is 1 or @building is 'EV'
      @building += @room_number[0]
      @room_number = @room_number.substring(1)

    @id = "#{@building}#{@room_number}"

  @load: (id, cb) ->
    room = new Room(id)
    room.loadClasses(cb)

  loadClasses: (cb) ->
    unless @classes?
      apiKey = process.env.UW_API_KEY || nconf.get('uwaterloo_api_key')
      api = new UWapi(apiKey)
      api.getClassesForRoom(@building, @room_number, (err, classes) =>
        @classes = classes.map (clas) -> new ClassMeeting(clas).attributes
        cb(null, @)
      )

  scheduleForDay: (day) ->
    new Schedule(@classes, day)
