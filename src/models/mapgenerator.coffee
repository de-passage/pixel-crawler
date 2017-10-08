Map = require "./map.coffee"
Tile = require "./tile.coffee"
{ Wall, EmptySpace } = require "./entityconstructors.coffee"

# Returns an array containing at index 0 the array of the map
generateMap = (player) ->
  map = new Map 100, 100, (i, j) ->
    if i < 3 or i >= 97 or j < 3 or j >= 97
      new Wall
    else
      new EmptySpace

  map.addPlayableEntityAt 50, 50, player

  return map





module.exports = generateMap
