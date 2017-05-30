# Defines the content of a single tile on the game map
class Tile
  constructor: (ter, es...) ->
    terrain = ter
    entities = es
  terrain: (t) ->
    if t? then terrain = t else terrain
  addEntity: (en) ->
    entities.push en
  removeEntity: (callback) ->
    i = idx for val, idx in entities when callback(val)
    entities.splice i, 1 if i?
# end class Tile

