# ############################
#       Controllers          #
# ############################
# Controller for individual display cells.
# Dispatch tile changing information to the correct cells
class TileController
  constructor: (@width, @height, @lookup, @tooltipManager) ->
    @tiles = new Array(@width * @height)
  registerTile: (x, y, f) ->
    @tiles[x + y * @width] = f
  updateTile: (x, y, data) ->
    @tiles[x + y * @width](@lookup data)
  onMouseEnter: (x, y, event) ->
    @tooltipManager.onMouseEnter(x, y, event)
  onMouseMove: (x, y, event) ->
    @tooltipManager.onMouseMove(x, y, event)
  onMouseLeave: (x, y) ->
    @tooltipManager.onMouseLeave()
# end class TileController

# Controller for the game itself
# Handles general event dispatching and calling the game engine
# when needed to run the game
class GameController
  contructor: (@map) ->
    @events = {}
  on: (event, action) ->
    @events[event] ?= []
    @events[event].push action
  emit: (event, args...) ->
    obs(args...) for obs in @events[event]
  render: ->
    @emit "render", @map

module.exports =
  TileController: TileController
  GameController: GameController
