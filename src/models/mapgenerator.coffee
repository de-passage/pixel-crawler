Array2D = require "./array2d.coffee"
Tile = require "./tile.coffee"

# Returns an array containing at index 0 the array of the map
generateMap = (player) ->
  map = new Array2D(100, 100)

  for i in [0...100]
    for j in [0...100]
      if i < 3 or i > 97 or j < 3 or j > 97
        a.set i, j, new Tile(new Wall)
      else
        entities = []
        entities.push player if i == 50 and j == 50
        a.set i,j,new Tile(new EmptySpace, entities)

  return map





module.exports = generateMap
