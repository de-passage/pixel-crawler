UserInputController = require "../src/controllers/userinput.coffee"

chai = require "chai"
chai.should()
sinon = require "sinon"

describe "UserInputController", ->
  state =
    a: sinon.stub()
    b: sinon.stub()
  ui = null

  beforeEach ->
    ui = new UserInputController state

  afterEach ->
    state.a.reset()
    state.b.reset()

  describe "#onEvent()", ->

    it "should store the matching function in the buffer property unless a callback was provided", ->
      (typeof ui.callback).should.equal "undefined"
      (typeof ui.buffer).should.equal "undefined"
      state.a.returns 42
      ui.onEvent key: "a"
      ui.buffer().should.equal 42

    it "should pass the return value of the function to the callback if it was provided", ->
      state.a.returns 42
      spy = sinon.spy()
      ui.callback = (f) -> spy f()
      ui.onEvent key: "a"
      sinon.assert.calledWith spy, 42

    it "should reset the callback to null after calling it", ->
      state.a.returns true
      ui.callback = ->
      ui.onEvent key: "a"
      chai.expect(ui.callback).to.equal null

  describe "#getInput()", ->

    spy = sinon.spy()

    afterEach ->
      spy.reset()

    it "should call the callback with the buffer if it exist", ->
      ui.buffer = -> 42
      ui.getInput spy
      sinon.assert.calledWith spy, 42

    it "should store the callback if no value is buffered", ->
      (typeof ui.buffer).should.equal "undefined"
      (typeof ui.callback).should.equal "undefined"
      ui.getInput spy
      sinon.assert.notCalled spy
      ui.callback((x) -> x)
      sinon.assert.calledOnce spy


    it "should reset the buffer to null if used", ->
      ui.buffer = -> 42
      ui.getInput spy
      chai.expect(ui.buffer).to.equal null
