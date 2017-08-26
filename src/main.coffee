ReactDOM = require "react-dom"
View = require "./views/tlview.coffee"
TileController = require "./controllers/tilecontroller.coffee"
GameLogic = require "./models/gamelogic.coffee"
mapGen = require "./models/mapgenerator.coffee"
Construct = require "./models/entityconstructors.coffee"
InputController = require "./controllers/userinput.coffee"

inputController = new InputController

player = Construct.Character(inputController, "player")

map = mapGen()



$ -> ReactDOM.render (View tileController: new TileController), $("#react-content")[0]
