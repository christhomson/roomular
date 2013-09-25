request = require('request')

module.exports = class API
  constructor: (apiKey) ->
    @apiKey = apiKey

  getCourseFromRoom: (room, done) ->
    apiURL = @apiBaseWithKey() + "&service=CourseFromRoom&q=#{room}"
    options = {
      uri: apiURL
      headers: {'User-Agent': 'Roomular (https://github.com/christhomson/roomular)'}
    }
    request(options, (err, res, body) ->
      try
        classes = JSON.parse(body).response.data.result
        done(null, classes)
      catch e
        done(err, {})
    )

  apiBaseWithKey: ->
    "http://api.uwaterloo.ca/public/v1/?key=#{@apiKey}"