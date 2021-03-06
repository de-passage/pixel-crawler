Array2D = require "./array2d.coffee"


# Wrapper for an Array2D of Tile, offering
# a proxy with access to only non-modifying operations
class Map


  constructor: (width, height, fill) ->
    @playableEntities = []
    @height = ->
      height
    @width = ->
      width
    map = new Array2D width, height
    if fill?
      for i in [0...width]
        for j in [0...height]
          map.set(i, j, fill(i, j))

    # The following functions are only proxies to the tiles and their
    # implementation is extremely similar so we can just metaprogram
    # them like so (2 cases):

    # For those, we just add the "At" suffix to the verb and directly call the function
    # from Tile with the given arguments
    [
      "terrain"
      "topLevelEntity"
      "removeEntity"
      "findEntity"
      "findEntities"
    ].forEach (name) =>
      @[name + "At"] = (x, y, args...) -> map.at(x, y)[name](args...)


    # The following have a different format and need special treatment.
    [
      ["setTerrainAt", (e, t) -> e.terrain(t)]
      ["entitiesAt", (e) -> e.entities]
      
    # We go over each name/function pair
    ].forEach (pair) =>
      [name, func] = pair
      # We add a key "name" to the object being constructed which value is a function
      # retrieving the tile at the given coordinates and applying to it the pair's "func"
      # with the arguments given by the caller
      @[name] = (x, y, args...) -> func(map.at(x,y), args...)

    # Add entity to the map and save its coordinates
    @addEntityAt = (x, y, e) ->
      e.x = x
      e.y = y
      map.at(x,y).addEntity e


  # Add a new entity to the given coordinates and reference it
  # in the playableEntities array for quick access
  addPlayableEntityAt: (x, y, e) ->
    @addEntityAt x, y, e
    @playableEntities.push e

  # Safely remove a playable entity matching callback from the map and the index
  removePlayableEntity: (callback) ->
    idx = i for val, i in @playableEntities when callback(val)
    if idx?
      el = @playableEntities.splice(idx, 1)[0]
      @removeEntityAt el.x, el.y, (el2)-> el.id() == el2.id()
      el
    else
      null

  # Move an entity destination coordinates
  moveEntity: (entity, x, y) ->
    xs = entity.x
    ys = entity.y
    return if entity.x == x and entity.y == y
    en = @removeEntityAt entity.x, entity.y, (e) -> e.id() == entity.id()
    throw "This entity is not in the right place..." unless en?
    en.x = x
    en.y = y
    @addEntityAt x, y, en

    #@controller.emit "move", xs, ys, x, y

  # Returns a proxy to the target Map. A proxy is only able to access read-only properties
  # of Map and sanitize their output (Entity objects) to ensure that only read-only 
  # operations can be done on them
  proxy: ->
    entitiesAt: (x, y) =>
      @entitiesAt(x, y).map (el) -> el.protected

    terrainAt: (x, y) =>
      @terrainAt(x, y).protected

    width: @width.bind @
    height: @height.bind @

module.exports = Map
