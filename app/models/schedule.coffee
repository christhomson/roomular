_ = require('underscore')

module.exports = class Schedule
  constructor: (classes, day) ->
    @timeslots = _.filter classes, (clas) -> clas.weekdays.match(day.regex())?

    @sort()
    @addGaps()

  sort: ->
    @timeslots.sort (a, b) ->
      parseInt(a.start_time.split(':')[0], 10) - parseInt(b.start_time.split(':')[0], 10)

  addGaps: ->
    @numberOfGaps = 0

    # Add in gaps.
    previousEndTime = [8, 30]
    _.each(_.clone(@timeslots), (clas, i) =>
      startTime = _.map(clas.start_time.split(':'), (digit) -> parseInt(digit, 10))

      if @calculateTimeDifference(previousEndTime, startTime) > 10
        @timeslots.splice(i + @numberOfGaps, 0, @gapClassForTimeframe(previousEndTime, startTime))
        @numberOfGaps++

      previousEndTime = _.map(clas.end_time.split(':'), (digit) -> parseInt(digit, 10))
    )

    lastClass = @timeslots[@timeslots.length - 1]
    lastEndTime = lastClass?.end_time.split(':').map (digit) -> parseInt(digit, 10)

    if lastClass and @calculateTimeDifference(lastEndTime, [22, 0]) > 10
      @timeslots.push(@gapClassForTimeframe(lastEndTime, [22, 0]))
      @numberOfGaps++

    @sort()

  gapClassForTimeframe: (startTime, endTime) ->
    # Pad timestamps, if necessary, for consistency w/ API data
    startTime[0] = if startTime[0] <= 9 then "0#{startTime[0]}" else startTime[0]
    endTime[0] = if endTime[0] <= 9 then "0#{endTime[0]}" else endTime[0]
    startTime[1] = if startTime[1] < 9 then "#{startTime[1]}0" else startTime[1]
    endTime[1] = if endTime[1] < 9 then "#{endTime[1]}0" else endTime[1]

    {
      start_time: startTime.join(':')
      end_time: endTime.join(':')
      halfHours: (endTime[0] - startTime[0]) * 2 + (Math.ceil((endTime[1] - startTime[1]) / 30.0))
      isGap: true
    }

  calculateTimeDifference: (startTime, endTime) ->
    (endTime[0] - startTime[0]) * 60 + (endTime[1] - startTime[1])
