chai = require "chai"
.should()

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
  ->
    display = []
    for i in [0...10]
      temp = []
      for j in [0...10]
        push = null
        # The coordinates are inverted to iterate through the width first. The second parameter
        # represents the vertical axis, but we are building lines instead of columns in the inner loop
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

playerTurn = -> type: Message.pass
monsterTurn = -> type: Message.pass

player = new Constructors.PlayableCharacter(playerTurn, 1, "blue")
monster = -> new Constructors.PlayableCharacter(monsterTurn, 2, "red")
map = mapGenerator()
controller = new GameController
map.addPlayableEntityAt 1, 1, player
map.addPlayableEntityAt 4, 1, monster()
map.addPlayableEntityAt 3, 6, monster()
map.addPlayableEntityAt 7, 3, monster()
map.addPlayableEntityAt 7, 3, monster()
showMap = showMap(map)
showMap()

logic = new GameLogic map, controller, actions

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

describe "Action sequence", ->

  it "should run properly", ->
    logic.startTurn() #returns a Promise

  it "should not do anything during turn 0, everyone passes", ->
    assertPlayerIsAt 1, 1
    assertMonsterAt 4, 1
    assertMonsterAt 3, 6
    assertMonsterAt 7, 3, 2

  it "should now be turn 1", ->
    logic.turn.should.equal 1



    


