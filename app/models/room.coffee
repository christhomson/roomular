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
        @classes = classes
        cb(null, @)
      )

  scheduleForDay: (day) ->
    _.filter @classes, (clas) -> clas.weekdays.match(day.regex())?

