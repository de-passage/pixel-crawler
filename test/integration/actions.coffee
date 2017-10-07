chai = require "chai"
chai.should()

_require = (folder,file) -> require "../../src/#{folder}/#{file}.coffee"
requireModel = (file) -> _require "models", file
requireController = (file) -> _require "controllers", file

GameLogic = requireModel "gamelogic"
GameController = requireController "gamecontroller"
Constructors = requireModel "entityconstructors"
Message = requireModel "message"
actions = requireModel "action"
mapGenerator = require "./helpers/mapgen.coffee"

showMap = (map) ->
  return (->) unless process.env["VERBOSE"]
  ->
    display = []
    for i in [0...10]
      temp = []
      for j in [0...10]
        push = null
        # The coordinates are inverted to iterate through the width first. The second parameter
        # represents the vertical axis, but we want to build lines instead of columns in the inner loop
        if map.terrainAt(j,i).property "seethrough"
          push = "."
        else
          push = "#"
        if (e = map.entitiesAt(j,i)).length > 0
          if e.length > 1
            push = "X"
          else
            switch e[0].property("color")
              when "blue"
                push = "P"
              when "red"
                push = "M"
        temp.push push

      display.push temp.join(" ")
    console.log "Map:"
    console.log display.join("\n")

# ################
# Initialization #
# ################

playerActions =
  [ { type: Message.pass }, { type: Message.move, direction: "right" }, { type: Message.move, direction: "right" } , { type: Message.move, direction: "right" } ]

playerTurn = (callback) ->
  callback playerActions.shift()

monsterTurn = (callback) -> callback type: Message.pass

player = new Constructors.PlayableCharacter(playerTurn, properties: { color: "blue", maxHealth: 10, health: 10 })
monster = -> new Constructors.PlayableCharacter(monsterTurn, properties: { color: "red", maxHealth: 10, health: 10 })
controller = new GameController
controller.on "error", (err) -> throw err
map = mapGenerator(controller)
map.addPlayableEntityAt 1, 1, player
map.addPlayableEntityAt 4, 1, monster()
map.addPlayableEntityAt 3, 6, monster()
map.addPlayableEntityAt 7, 3, monster()
map.addPlayableEntityAt 7, 3, monster()
showMap = showMap(map)

logic = new GameLogic map, controller, actions

sword = new Constructors.Weapon properties: damage: normal: 3

# #########
# Helpers #
# #########

assertPlayerIsAt = (x, y) ->
  e = map.entitiesAt x, y
  e.length.should.equal 1
  e[0].property("color").should.equal "blue"
  player.x.should.equal x
  player.y.should.equal y

assertMonsterAt = (x, y, n = 1) ->
  e = map.entitiesAt x, y
  e.length.should.equal n
  for m in e
    m.property("color").should.equal "red"
    m.x.should.equal x
    m.y.should.equal y

assertNoOneAt = (x, y) ->
  map.entitiesAt(x,y).length.should.equal 0

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
    showMap()
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
