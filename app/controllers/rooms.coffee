nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' })
_ = require('underscore')
Day = require('../models/day')
Room = require('../models/room')
UWapi = require('../models/api')

class RoomsController
  exports.index = (req, res) ->
    res.render('rooms_index')

  exports.show = (req, res) ->
    day = new Day()
    console.log(req.room.scheduleForDay(day))
    res.render('rooms_show', {
      room: req.room
      day: day.attributes()
      timeslots: req.room.scheduleForDay(day)
    })
