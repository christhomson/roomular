module.exports = (app) ->
  LATEST_ROOMS = "roomular:rooms:latest"

  app.get('/', (req, res) ->
    process.redis.lrange LATEST_ROOMS, 0, 9, (err, rooms) ->
      res.render('index', {recentRooms: rooms})
  )