Array2D = require "./array2d.coffee"

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
    # them like so:
    [
      ["terrainAt", (e) -> e.terrain()]
      ["setTerrainAt", (e, t) -> e.terrain(t)]
      ["addEntityAt", (e, en) -> e.addEntity(en)]
      ["entitiesAt", (e) -> e.entities]
      ["topLevelEntityAt", (e) -> e.topLevelEntity()]
    ].forEach (f) =>
      # For each pair name/function
      [name, func] = f
      # Create on "this" a key whose value is a function taking a pair of coordinates,
      # which retrieves the corresponding tile then apply to it the appropriate function
      @[name] = (x, y, args...) -> func(map.at(x, y), args...)

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
