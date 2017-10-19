MessageConstructor = require "../../../src/models/messageconstructor.coffee"

attackRight = (map) ->
  id = map.entitiesAt(@x + 1, @y)[0].id()
  MessageConstructor.attack @x + 1, @y, id

playerActions = [
  MessageConstructor.pass(),
  MessageConstructor.move("right"),
  MessageConstructor.move("right"),
  MessageConstructor.move("right"),
  attackRight,
  attackRight,
  attackRight,
  attackRight,
  -> MessageConstructor.spell "heal", @x, @y, @id()
]

module.exports =
  playerTurn: (play, map) ->
    play if typeof (c = playerActions.shift()) is "function" then c.call(this, map) else c

  monsterTurn: (play, map) ->
    [[0, 1], [0, -1], [1, 0], [-1, 0]].forEach (p) =>
      [x, y] = p
      nX = @x + x
      nY =  @y + y
      if nX >= 0 and nY >= 0
        entities = map.entitiesAt(nX, nY)
        pl = entity for entity in entities when entity.property("team") == "player"
        if pl
          return play MessageConstructor.attack nX, nY, pl.id()
    play MessageConstructor.pass()
