# Controller for individual display cells.
# Dispatch tile changing information to the correct cells
class TileController
  # Constructor, takes an optional lookup parameter defining how to convert input data
  # to pass to the cell
  constructor: (@lookup) ->
    @tiles = []

  # Register a callback to use when the cell at the given coordinates is to
  # be updated
  registerTile: (x, y, f) ->
    @tiles[x + y * @width] = f

  # Convert the data if necessary and call the cell
  # at the given coordinates to update its display
  updateTile: (x, y, data) ->
    l =
      if typeof @lookup == "function"
        @lookup data
      else if @lookup? and @lookup[data]?
        @lookup[data]
      else data
    @tiles[x + y * @width] data

  # Notifies that the mouse cursor entered the cell at the given coordinates
  mouseEnter: (x, y, event) ->
    @onMouseEnter?(x, y, event)

  # Notifies that the mouse cursor moved over the cell at the given coordinates
  mouseMove: (x, y, event) ->
    @onMouseMove?(x, y, event)
  #
  # Notifies that the mouse cursor left the cell at the given coordinates
  mouseLeave: (x, y) ->
    @onMouseLeave?()
# end class TileController

module.exports = TileController

