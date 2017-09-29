_require = (folder,file) -> require "../../src/#{folder}/#{file}.coffee"
requireModel = (file) -> _require "models", file
requireController = (file) -> _require "controllers", file

GameLogic = requireModel "gamelogic"
GameController = requireController "gamecontroller"
actions = requireModel "action"
mapGenerator = require "./helpers/mapgen.coffee"

showMap = (map) ->
  ->
    display = []
    for i in [0...10]
      temp = []
      for j in [0...10]
        push = null
        if map.terrainAt(i,j).property "seethrough"
          push = "."
        else
          push = "X"
        if (e = map.entitiesAt(i,j)).length > 0
          console.log i, j, e.length
          if e.length > 1
            push = "+"
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

describe "Action sequence", ->
  controller = new GameController
  map = mapGenerator()
  showMap = showMap(map)
  showMap()
  logic = new GameLogic map, controller, actions

  it "should not do anything during turn 0, everyone passes", ->
    logic.startTurn(null)
    


