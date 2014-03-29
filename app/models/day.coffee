request = require('request')

module.exports = class Day
  DAYS = [
    { name: "Sunday", regex: /Su/ }
    { name: "Monday", regex: /M/ }
    { name: "Tuesday", regex: /(T$|T[^h])/ }
    { name: "Wednesday", regex: /W/ }
    { name: "Thursday", regex: /Th/ }
    { name: "Friday", regex: /F/ }
    { name: "Saturday", regex: /(S$|S[^u])/ }
  ]

  constructor: (date) ->
    @date = date || new Date("2014-03-27")

  name: ->
    DAYS[@date.getDay()].name

  regex: ->
    DAYS[@date.getDay()].regex

  attributes: ->
    name: @name()
