Array2D = require "./array2d.coffee"

class Map
  constructor: (width, height, fill) ->
    @height = ->
      height
    @width = ->
      width
    @map = new Array2D width, height
    if fill?
      for i in [0...width]
        for j in [0...height]
          @map.set(i, j, fill(i, j))

  terrainAt: (x, y) ->
    @map.at(x, y).terrain()
    
  entitiesAt: (x, y) ->
    @map.at(x, y).entities

  topLevelEntityAt: (x, y) ->
    @map.at(x, y).topLevelEntity()

  proxy: ->
    entities: (x, y) =>
      @entitiesAt(x, y).map (el) ->
        id: el.id
        property: el.property.bind(el)

    terrain: (x, y) =>
      ter = @terrainAt(x, y)
      id: ter.id
      property: ter.property.bind(el)


module.exports = Map
