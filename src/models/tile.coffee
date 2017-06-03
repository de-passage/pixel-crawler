# Defines the content of a single tile on the game map

class Tile
  # A tile is constructed from a piece of terrain and a list of entities
  constructor: (ter, es...) ->
    terrain = ter
    entities = es

  terrain: (t) ->
    if t? then terrain = t else terrain

  addEntity: (en) ->
    entities.push en

  removeEntity: (callback) ->
    i = idx for val, idx in entities when callback(val)
    if i?
      entities.splice i, 1
      true
    else
      false
# end class Tile


