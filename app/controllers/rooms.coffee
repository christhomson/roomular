nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' })
_ = require('underscore')
Day = require('../models/day')
Room = require('../models/room')
UWapi = require('../models/api')

class RoomsController
  exports.index = (req, res) ->
    if req.query.room
      res.redirect("/rooms/#{req.query.room}")
    else
      res.render('rooms_index')

  exports.show = (req, res) ->
    day = new Day()
    res.render('rooms_show', {
      room: req.room
      day: day.attributes()
      schedule: req.room.scheduleForDay(day)
    })
