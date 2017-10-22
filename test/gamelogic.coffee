GameLogic = require "../src/models/gamelogic.coffee"
Map = require "../src/models/map.coffee"
Tile = require "../src/models/tile.coffee"
Entity = require "../src/models/entity.coffee"
GameController = require "../src/controllers/gamecontroller.coffee"
chai = require "chai"
sinon = require "sinon"
chai.should()

describe "GameLogic", ->

  logic = null
  map = new Map 10, 10, -> new Tile new Entity
  controller = new GameController
  sinon.spy(controller, "emit")

  beforeEach ->
    logic = new GameLogic map, controller

  afterEach ->
    controller.emit.reset?()

  it "should emit a new_turn event at the start of a new turn", ->
    logic.playTurn()
    sinon.assert.calledWith controller.emit, "new_turn"

  it "should emit a end_turn event at the end of a new turn", ->
    logic.playTurn()
    sinon.assert.calledWith controller.emit, "end_turn"

  it "should increment the turn count at the end of playTurn()", ->
    turn = logic.turn
    logic.playTurn().then ->
      logic.turn.should.equal turn + 1

  it "should call its callback once playTurn() is done", ->
    callback = sinon.spy()
    logic.playTurn(-> callback(); Promise.resolve()).then ->
      sinon.assert.calledOnce(callback)

