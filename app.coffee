express = require('express')
nconf = require('nconf')
nconf.argv().env().file({ file: 'config/local.json' });
exphbs  = require('express3-handlebars')
redis = require('redis')

process.redis = redis.createClient() # assumes localhost:6379
@app = express()


@app.engine('handlebars', exphbs({
  defaultLayout: 'main'
  helpers: {
    downcase: (str) -> str.toLowerCase()
    friendlyRoomName: (roomName) ->
      components = roomName.match(/([A-Za-z]*)([0-9]*)/)

      if components[1].length is 1 or components[1] is 'EV'
        components[1] = components[1] + components[2][0]
        components[2] = components[2].substring(1)

      "#{components[1]} #{components[2]}"

    buildingName: (roomName) ->
      components = roomName.match(/([A-Za-z]*)([0-9]*)/)

      if components[1].length is 1 or components[1] is 'EV'
        components[1] + components[2][0]
      else
        components[1]

    roomNumber: (roomName) ->
      components = roomName.match(/([A-Za-z]*)([0-9]*)/)

      if components[1].length is 1 or components[1] is 'EV'
        components[2].substring(1)
      else
        components[2]

    mixpanelToken: -> nconf.get('mixpanel_token')
  }
}))

@app.set('view engine', 'handlebars')
@app.use(express.static(__dirname + '/public'));

@routes = {
  room: require('./routes/room')(@app)
  index: require('./routes/index')(@app)
}

port = process.env.PORT || nconf.get('server').port
@app.listen(port)
console.log("Roomular started on port #{port}.")