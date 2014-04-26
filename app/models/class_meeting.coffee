module.exports = class ClassMeeting
  constructor: (attributes) ->
    @attributes = attributes

    @setInstructor()
    @setClassType()
    @setHalfHours()

  setInstructor: ->
    # [ 'Nguyen,Trien T' ] => "Trien T Nguyen"
    @attributes.instructor = @attributes.instructors?[0]?.split(',')?.reverse()?.join(' ') || "Unknown Instructor"

  setClassType: ->
    # See https://uwaterloo.ca/quest/undergraduate-students/glossary-of-terms.
    @attributes.classType = switch(@attributes.section.split(' ')[0])
      when 'CLN' then 'Clinic'
      when 'DIS' then 'Discussion'
      when 'ENS' then 'Ensemble'
      when 'ESS' then 'Essay'
      when 'FLD' then 'Field Studies'
      when 'LAB' then 'Lab'
      when 'LEC' then 'Lecture'
      when 'ORL' then 'Oral Conversation'
      when 'PRA' then 'Practicum'
      when 'PRJ' then 'Project'
      when 'RDG' then 'Reading'
      when 'SEM' then 'Seminar'
      when 'STU' then 'Studio'
      when 'TLC' then 'Test Slot - Lecture'
      when 'TST' then 'Test Slot'
      when 'TUT' then 'Tutorial'
      when 'WRK' then 'Work Term'
      when 'WSP' then 'Workshop'
      else 'Meeting'

  setHalfHours: ->
    startTime = @attributes.start_time.split(':')
    endTime = @attributes.end_time.split(':')
    hours = endTime[0] - startTime[0]
    minutes = endTime[1] - startTime[1]

    @attributes.halfHours = (hours * 2) + (Math.ceil(minutes / 30.0))
