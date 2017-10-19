chai = require "chai"
chai.should()

_require = (folder,file) -> require "../../src/#{folder}/#{file}.coffee"
requireModel = (file) -> _require "models", file
requireController = (file) -> _require "controllers", file

GameLogic = requireModel "gamelogic"
GameController = requireController "gamecontroller"
Constructors = requireModel "entityconstructors"
Message = requireModel "message"
MessageConstructor = requireModel "messageconstructor"
actions = requireModel "action"
mapGenerator = require "./helpers/mapgen.coffee"
showMap = require "./helpers/showMap.coffee"
assertions = require "./helpers/assertions.coffee"

# ################
# Initialization #
# ################

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

playerTurn = (play, map) ->
  play if typeof (c = playerActions.shift()) is "function" then c.call(this, map) else c

monsterTurn = (play, map) ->
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

sword = new Constructors.Weapon properties: damage: normal: 3
claw = new Constructors.Weapon properties: damage: normal: 1
player = new Constructors.PlayableCharacter(playerTurn, properties: { color: "blue", maxHealth: 10, health: 10, team: "player" })
monster = -> new Constructors.PlayableCharacter(monsterTurn, properties: { color: "red", maxHealth: 10, health: 10, team: "monster", weapon: claw.clone() })
controller = new GameController
controller.on "error", (err) -> throw err
controller.on "move", (e) -> if(process.env["VERBOSE"]) then console.log "move", e.caller.property("team"), e.args...
controller.on "attack", (e) -> if(process.env["VERBOSE"]) then console.log "attack", e.caller.property("team"), e.args...
map = mapGenerator(controller)
map.addPlayableEntityAt 1, 1, player
map.addPlayableEntityAt 4, 1, monster()
map.addPlayableEntityAt 3, 6, monster()
map.addPlayableEntityAt 7, 3, monster()
map.addPlayableEntityAt 7, 3, monster()
showMap = showMap(map)
{ assertMonsterAt, assertNoOneAt, assertPlayerIsAt } = assertions(map, player)

logic = new GameLogic map, controller, actions, entityFilter: (list) -> (e for e in list when !e.property("dead"))

# #######
# Tests #
# #######

describe "Action sequence", ->

  it "should be properly initialized", ->
    player.react("changeWeapon", sword)
    player.property("health").should.equal 10
    player.property("maxHealth").should.equal 10
    player.property("damage").normal.should.equal 3
    player.property("color").should.equal "blue"

    [[4,1],[3,6],[7,3]].forEach (coords) ->
      for m in map.entitiesAt coords...
        m.property("health").should.equal 10
        m.property("maxHealth").should.equal 10
        m.property("color").should.equal "red"


  it "should run properly", ->
    #showMap()
    logic.startTurn(showMap) #returns a Promise

  it "should not do anything during turn 0, everyone passes", ->
    assertPlayerIsAt 1, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2

  it "should now be turn 1", ->
    logic.turn.should.equal 1

  it "should run turn 1 properly", ->
    logic.startTurn(showMap)

  it "should have moved the player right", ->
    assertPlayerIsAt 2, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2
    assertNoOneAt 1, 1

  it "should now be turn 2", ->
    logic.turn.should.equal 2
    # Seems to be working, will omit it from now on

  it "should run turn 2 properly", ->
    logic.startTurn(showMap)

  it "should have moved the player right", ->
    assertPlayerIsAt 3, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2
    assertNoOneAt 2, 1

  it "should fail to move on the third movement (can't go through monster)", ->
    logic.startTurn(showMap)
    assertPlayerIsAt 3, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2
    assertNoOneAt 2, 1

  it "should run turn 4 properly", ->
    logic.startTurn(showMap)

  it "should resolve attacks properly", ->
    monster = map.topLevelEntityAt(4, 1)
    monster.property("health").should.equal 7
    player.property("health").should.equal 9

  it "should run turn 5, 6 and 7 properly", ->
    logic.startTurn()
    logic.startTurn()
    logic.startTurn(showMap)

  it "should now be turn 8", ->
    logic.turn.should.equal 8

  it "should have seen the death of the monster", ->
    monster = map.topLevelEntityAt 4, 1
    monster.property("dead").should.equal true

  it "should have left the player with 6 hp", ->
    player.property("health").should.equal 6

  it "should play turn 8 properly", ->
    logic.startTurn(showMap)

  it "should have healed the player through the heal spell", ->
    player.property("health").should.equal 10

