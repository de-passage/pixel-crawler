
# Controller for the game itself
# Handles general event dispatching and calling the game engine
# when needed to run the game
class GameController
  constructor: ->
    @events = {}

  on: (event, action) ->
    @events[event] ?= []
    @events[event].push action

  emit: (event, args...) ->
    obs(args...) for k, obs of @events[event] if @events[event]

module.exports = GameController
