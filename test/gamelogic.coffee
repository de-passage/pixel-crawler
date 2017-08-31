GameLogic = require "../src/models/gamelogic.coffee"
chai = require "chai"
sinon = require "sinon"
chai.should()

controller =
  emit: sinon.spy()

map =
  at: sinon.spy()
  forEach: sinon.spy()

describe "GameLogic", ->

  logic = null

  beforeEach ->
    logic = new GameLogic map, controller

  afterEach ->
    controller.emit.reset()
    map.at.reset()
    map.forEach.reset()

  it "should emit a NewTurn event at the start of a new turn", ->
    sinon.assert.calledWith controller.emit, "NewTurn"

  it "is pending"

