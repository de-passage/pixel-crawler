Map = require "../../../src/models/map.coffee"
Tile = require "../../../src/models/tile.coffee"
Constructors = require "../../../src/models/entityconstructors.coffee"
Message = require "../../../src/models/message.coffee"

module.exports =
  ->
    playerTurn = -> Message.pass
    monsterTurn = -> Message.pass
    W = new Constructors.Wall
    E = new Constructors.EmptySpace
    player = new Constructors.PlayableCharacter(playerTurn, 1, "blue")
    monster = -> new Constructors.PlayableCharacter(monsterTurn, 2, "red")
    m = new Map 10, 10, (x,y) ->
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
    m.addPlayableEntityAt 1, 1, player
    m.addPlayableEntityAt 3, 1, monster()

    m
