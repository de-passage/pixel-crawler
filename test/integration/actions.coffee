chai = require "chai"
chai.should()

_require = (folder,file) -> require "../../src/#{folder}/#{file}.coffee"
requireModel = (file) -> _require "models", file
requireController = (file) -> _require "controllers", file

GameLogic = requireModel "gamelogic"
GameController = requireController "gamecontroller"
Constructors = requireModel "entityconstructors"
actions = requireModel "action"
mapGenerator = require "./helpers/mapgen.coffee"
showMap = require "./helpers/showMap.coffee"
assertions = require "./helpers/assertions.coffee"

# ################
# Initialization #
# ################

{ playerTurn, monsterTurn } = require "./helpers/inputfunctions.coffee"

sword = new Constructors.Weapon properties: damage: normal: 3
claw = new Constructors.Weapon properties: damage: normal: 1
player = new Constructors.PlayableCharacter(playerTurn, properties: { color: "blue", maxHealth: 10, health: 10, team: "player", spells: ["heal"] })
monster = -> new Constructors.PlayableCharacter(monsterTurn, properties: { color: "red", maxHealth: 10, health: 10, team: "monster", weapon: claw.clone() })


controller = new GameController
controller.on "error", (err) ->
  if(process.env["VERBOSE"])
    console.log "ERROR: #{err.message}"
  throw err
controller.on "move", (e) -> if(process.env["VERBOSE"]) then console.log "move", e.caller.property("team"), e.args...
controller.on "attack", (e) ->
  if(process.env["VERBOSE"])
    target = map.findEntityAt(e.args[0], e.args[1], (em)-> em.id() == e.args[2])
    console.log "#{e.caller.property("team")} at (#{e.caller.x}, #{e.caller.y}) with id: #{e.caller.id()} attacked #{target.property("team")} with id: #{target.id()} at (#{target.x}, #{target.y})"
controller.on "spell", (e) ->
  if(process.env["VERBOSE"])
    console.log "#{e.caller.property("team")} at (#{e.caller.x}, #{e.caller.y}) with id: #{e.caller.id()} used `#{e.args[2]}`"
controller.on "pass", (e) -> if(process.env["VERBOSE"]) then console.log "#{e.caller.property("team")} at (#{e.caller.x}, #{e.caller.y}) with id: #{e.caller.id()} passed its turn"
controller.on "new_turn", (t) -> if(process.env["VERBOSE"]) then console.log "New turn: #{t}"
controller.on "end_turn", (t) -> if(process.env["VERBOSE"]) then console.log "End of turn: #{t}"
map = mapGenerator(controller)
map.addPlayableEntityAt 1, 1, player
map.addPlayableEntityAt 4, 1, monster()
map.addPlayableEntityAt 3, 6, monster()
map.addPlayableEntityAt 7, 3, monster()
map.addPlayableEntityAt 7, 3, monster()
showMap = showMap(map)

{ assertMonsterAt, assertNoOneAt, assertPlayerIsAt } = assertions(map, player)

logic = new GameLogic map, controller.emit.bind(controller),
  actions: actions,
  initiative: (list) -> (e for e in list when !e.property("dead")),
  play: (entity, args) -> entity.property "play", args

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
    logic.playTurn(showMap) #returns a Promise

  it "should not do anything during turn 0, everyone passes", ->
    assertPlayerIsAt 1, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2

  it "should now be turn 1", ->
    logic.turn.should.equal 1

  it "should run turn 1 properly", ->
    logic.playTurn(showMap)

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
    logic.playTurn(showMap)

  it "should have moved the player right", ->
    assertPlayerIsAt 3, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2
    assertNoOneAt 2, 1

  it "should have hit the player with an attack from the closest monster since it is in range", ->
    player.property("health").should.equal 9

  it "should now be turn 3", ->
    logic.turn.should.equal 3

  it "should fail to move on the third movement (can't go through monster)", ->
    logic.playTurn(showMap)
    assertPlayerIsAt 3, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2
    assertNoOneAt 2, 1

  it "should still have resolved other player's turns despite the error", ->
    player.property("health").should.equal 8

  it "should now be turn 4", ->
    logic.turn.should.equal 4

  it "should run turn 4 properly", ->
    logic.playTurn(showMap)

  it "should resolve attacks properly", ->
    monster = map.topLevelEntityAt(4, 1)
    monster.property("health").should.equal 7
    player.property("health").should.equal 7

  it "should run turn 5, 6 and 7 properly", ->
    logic.playTurn().then ->
      logic.playTurn().then ->
        logic.playTurn(showMap)

  it "should now be turn 8", ->
    logic.turn.should.equal 8

  it "should have seen the death of the monster", ->
    monster = map.topLevelEntityAt 4, 1
    monster.property("dead").should.equal true

  it "should have left the player with 5 hp", ->
    player.property("health").should.equal 4

  it "should play turn 8 properly", ->
    logic.playTurn(showMap)

  it "should have healed the player through the heal spell", ->
    player.property("health").should.equal 9

