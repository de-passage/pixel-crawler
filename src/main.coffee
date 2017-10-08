ReactDOM = require "react-dom"
View = require "./views/tlview.coffee"
TileController = require "./controllers/tilecontroller.coffee"
GameLogic = require "./models/gamelogic.coffee"
GameController = require "./controllers/gamecontroller.coffee"
mapGen = require "./models/mapgenerator.coffee"
Construct = require "./models/entityconstructors.coffee"
InputController = require "./controllers/userinput.coffee"
actions = require "./models/action.coffee"
Message = require "./models/message.coffee"

state =
  a: ->
    type: Message.move
    direction: "left"
  w: ->
    type: Message.move
    direction: "up"
  s: ->
    type: Message.move
    direction: "down"
  d: ->
    type: Message.move
    direction: "right"

inputController = new InputController state
game = new GameController

player = Construct.PlayableCharacter(inputController.getInput)

map = mapGen(player)
tileController = new TileController map, (tile) ->
  tile.property "color"


logic = new GameLogic(map, game, actions)

game.on "move", (e) ->
  [xd, yd, xs, ys] = e.args
  tileController.updateTile(xs, ys)
  tileController.updateTile(xd, yd)

game.on "error", (err, details) ->
  console.log "Error: ", err.message, details
      
startTurn = ->
  logic.startTurn startTurn

$ ->
  ReactDOM.render (View tileController: tileController, inputController: inputController), $("#react-content")[0]
  $(document).keypress inputController.onEvent
  startTurn()
