ReactDOM = require "react-dom"
View = require "./views/tlview.coffee"
TileController = require "./controllers/tilecontroller.coffee"
GameLogic = require "./models/gamelogic.coffee"
GameController = require "./controllers/gamecontroller.coffee"
mapGen = require "./models/mapgenerator.coffee"
Construct = require "./models/entityconstructors.coffee"
InputController = require "./controllers/userinput.coffee"

inputController = new InputController
tileController = new TileController (tile) ->
  data = tile.
  data.property "color"

player = Construct.Character(inputController, "player", "blue")

map = mapGen()

game = new GameController

logic = new GameLogic(map, game)

game.on "NewTurn", ->
  height = tileController.height()
  width = tileController.width()
  for i in [0...height]
    for j in [0...width]
      tileController.updateTile(i, j, map.at(i, j).topLevelEntity())
      


$ ->
  ReactDOM.render (View tileController: tileController, inputController: inputController), $("#react-content")[0]
  logic.startTurn()
