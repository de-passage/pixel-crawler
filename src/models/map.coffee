Array2D = require "./array2d.coffee"

# Wrapper for an Array2D of Tile, offering
# a proxy with access to only non-modifying operations
class Map
  constructor: (width, height, fill) ->
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
      "addEntity"
      "topLevelEntity"
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

  proxy: ->
    entities: (x, y) =>
      @entitiesAt(x, y).map (el) ->
        id: el.id
        property: el.property.bind(el)

    terrain: (x, y) =>
      ter = @terrainAt(x, y)
      id: ter.id
      property: ter.property.bind(el)

###
  terrainAt: (x, y) ->
    @map.at(x, y).terrain()

  setTerrainAt: (x, y, t) ->
    @map.at(x, y).terrain(t)
    
  addEntity: (x, y, entity) ->
    @map.at(x,y).addEntity(entity)

  entitiesAt: (x, y) ->
    @map.at(x, y).entities

  topLevelEntityAt: (x, y) ->
    @map.at(x, y).topLevelEntity()
###


module.exports = Map
