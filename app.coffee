express = require 'express'
nconf = require 'nconf'
nconf.argv().env().file({ file: 'config/local.json' })
hbs = require 'express-hbs'
Resource = require 'express-resource'
Room = require './app/models/room'

require('./app/views/helpers')()

@app = express()
module.exports = @app

@app.engine('hbs', hbs.express3({
  defaultLayout: 'app/views/layouts/application'
  helpers: {
    downcase: (str) -> str.toLowerCase()
    upcase: (str) -> str.toUpperCase()
    mixpanelToken: -> nconf.get('mixpanel_token')
  }
}))

@app.set('views', __dirname + '/app/views/')
@app.set('view engine', 'hbs')
@app.use(express.static(__dirname + '/public'))
@app.resource('rooms', require('./app/controllers/rooms'), { load: Room.load })

@app.get '/', (req, res) -> res.redirect('/rooms')

@app.get '/rooms/:building/:room/:day?', (req, res) ->
  path = "/rooms/#{req.params.building}#{req.params.room}"
  path += "?day=#{req.params.day}" if req.params.day?
  res.redirect(path)

unless module.parent?
  port = process.env.PORT || nconf.get('server').port
  @app.listen(port)
  console.log("Roomular started on port #{port}.")
