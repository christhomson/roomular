request = require('request')

module.exports = class API
  constructor: (apiKey) ->
    @apiKey = apiKey

  getClassesForRoom: (building, room, done) ->
    apiURL = @apiURLForEndpoint("buildings/#{building}/#{room}/courses")

    options = {
      uri: apiURL
      headers: {'User-Agent': 'Roomular (https://github.com/christhomson/roomular)'}
    }
    request(options, (err, res, body) ->
      try
        classes = JSON.parse(body).data
        done(null, classes)
      catch e
        done(err, [])
    )

  apiURLForEndpoint: (endpoint) ->
    "http://api.uwaterloo.ca/v2/#{endpoint}.json?key=#{@apiKey}"
