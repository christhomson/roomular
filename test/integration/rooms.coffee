assert = require('assert')
Browser = require('zombie')
app = require('../../app')

describe "[Integration] Finding a room's schedule", ->
  before ->
    @server = app.listen(3000)

  beforeEach ->
    @browser = new Browser({ site: 'http://127.0.0.1:3000' })

  after (done) ->
    @server.close(done)

  it "should be possible to navigate to a room's schedule", (done) ->
    @browser.visit('/', =>
      assert.ok(@browser.success)

      @browser.fill('room', 'MC 2054').pressButton('Find schedule', =>
        assert.ok(@browser.success)
        assert @browser.queryAll(".classes li").length > 0
        assert @browser.queryAll(".alert").length is 0

        done()
      )
    )
