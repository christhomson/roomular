request = require('request')

module.exports = class Room
  constructor: (buildingAndRoom) ->
    buildingAndRoom = buildingAndRoom.split(/\s/).join('')
    roomParts = buildingAndRoom.match(/([A-Za-z]*)([0-9]*)/)
    @building = roomParts[1].toUpperCase()
    @room_number = roomParts[2]

    if @building.length is 1 or @building is 'EV'
      @building += @room[0]
      @room = @room.substring(1)

