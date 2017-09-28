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
    ["playTurn", "startTurn"].forEach (e) ->
      logic[e].restore?()

  it "should emit a NewTurn event at the start of a new turn", ->
    logic.playTurn = sinon.spy()
    logic.startTurn()
    sinon.assert.calledWith controller.emit, "NewTurn"

  it "should call it's own playTurn() method once startTurn() is done", ->
    logic.playTurn = sinon.spy()
    # startTurn implicitely returns the promise used to call playTurn, we can then hook
    # on to that to chain a new promise and return it for mocha to test when it's done
    logic.startTurn().then ->
      sinon.assert.calledOnce(logic.playTurn)

  it "should increment the turn count on playTurn()", ->
    turn = logic.turn
    logic.startTurn = sinon.spy()
    logic.playTurn()
    logic.turn.should.equal turn + 1

  it "should call startTurn() again once playTurn() is done", ->
    logic.startTurn = sinon.spy()
    logic.playTurn()
    sinon.assert.calledOnce(logic.startTurn)

