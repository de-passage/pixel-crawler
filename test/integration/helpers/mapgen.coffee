Map = require "../../../src/models/map.coffee"
Constructors = require "../../../src/models/entityconstructors.coffee"

module.exports =
  (controller) ->

    W = new Constructors.Wall
    E = new Constructors.EmptySpace

    new Map 10, 10, controller, (x,y) ->
      # The representation is inverted from what it will look like since the inner
      # arrays actually represent columns
      [ [ W, W, W, W, W, W, W, W, W, W ]
        [ W, E, W, E, E, E, E, E, E, W ]
        [ W, E, W, E, E, W, E, E, E, W ]
        [ W, E, W, W, W, W, E, E, E, W ]
        [ W, E, E, E, W, E, E, W, W, W ]
        [ W, E, E, E, W, E, E, E, E, W ]
        [ W, E, W, W, W, W, W, E, E, W ]
        [ W, E, E, E, E, E, W, W, E, W ]
        [ W, E, E, E, E, E, E, E, E, W ]
        [ W, W, W, W, W, W, W, W, W, W ] ][x][y].clone()
