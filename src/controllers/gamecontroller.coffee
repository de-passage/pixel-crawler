
# Controller for the game itself
# Handles general event dispatching and calling the game engine
# when needed to run the game
class GameController
  contructor: ->
    @events = {}
  on: (event, action) ->
    @events[event] ?= []
    @events[event].push action
  emit: (event, args...) ->
    obs(args...) for obs in @events[event]
  render: ->
    @emit "render", map

module.exports = GameController
