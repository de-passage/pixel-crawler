# Defines the content of a single tile on the game map

class Tile
  # A tile is constructed from a piece of terrain and a list of entities
  constructor: (ter, es...) ->
    @t = ter
    @entities = es

  terrain:  (t) ->
    if t? then @t = t else @t

  addEntity: (en) ->
    @entities.push en

  removeEntity: (callback) ->
    i = idx for val, idx in @entities when callback(val)
    if i?
      @entities.splice(i, 1)[0]
    else
      null

  findEntity: (callback) ->
    return @findEntities(callback)[0] || null

  findEntities: (callback) ->
    return (val for val in @entities when callback(val))

  topLevelEntity: ->
    if @entities.length
      @entities[@entities.length - 1]
    else
      @terrain()


# end class Tile

module.exports = Tile
