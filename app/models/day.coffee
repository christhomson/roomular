_ = require('underscore')

module.exports = class Day
  DAYS = [
    { name: "Sunday", regex: /Su/, index: 0 }
    { name: "Monday", regex: /M/, index: 1 }
    { name: "Tuesday", regex: /(T$|T[^h])/, index: 2 }
    { name: "Wednesday", regex: /W/, index: 3 }
    { name: "Thursday", regex: /Th/, index: 4 }
    { name: "Friday", regex: /F/, index: 5 }
    { name: "Saturday", regex: /(S$|S[^u])/, index: 6 }
  ]

  constructor: (date) ->
    if date instanceof Date
      @date = DAYS[date.getDay()]
    else if typeof date is 'string'
      @date = _.find(DAYS, (day) -> day.name.toLowerCase() is date.toLowerCase())
    else
      @date = DAYS[new Date().getDay()]

    @date = @nextWeekday()

  name: ->
    @date.name

  regex: ->
    @date.regex

  previousWeekday: ->
    if @date.index is 6 or @date.index <= 1
      DAYS[5]
    else
      DAYS[@date.index - 1]

  nextWeekday: ->
    if @date.index >= 5 or @date.index is 0
      DAYS[1]
    else
      DAYS[@date.index + 1]

  attributes: ->
    name: @name()
    previousWeekday: @previousWeekday()
    nextWeekday: @nextWeekday()
