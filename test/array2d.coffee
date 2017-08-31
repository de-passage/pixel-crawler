Array2D = require "../src/models/array2d.coffee"
chai = require "chai"
chai.should()

describe "Array2D", ->
  array = null

  beforeEach ->
    array = new Array2D 10, 10

  it "should be constructed with two non null dimensions", ->
    (-> new Array2D 10).should.throw()
    (-> new Array2D).should.throw()
    (-> new Array2D 0, 10).should.throw()


  publicInterface = ["height", "width", "set", "at", "forEach"]
  it "should only expose a the following public interface: #{publicInterface.join(", ")}", ->
    count = 0
    for k, v of array
      count++
      (k in publicInterface).should.equal true

    count.should.equal publicInterface.length

  it "should throw an error if set() or at() is called out of bounds", ->
    failingValues = [
      [10, 0]
      [15, 4]
      [9, 10]
      [0, 11]
      [-1, 0]
      [-1, -1]
      [0, -1]
    ]

    for method in ["set", "at"]
      for v in failingValues
        ( -> array[method] f..., 0 ).should.throw

  it "should pass correct values to the callback to forEach()", ->
    a = new Array 10
    for i in [0...9]
      a[i] = new Array(10)


