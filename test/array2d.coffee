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
    width = 8
    height = 10
    a = new Array width
    array = new Array2D width, height
    for i in [0...width]
      a[i] = new Array height
      for j in [0...height]
        a[i][j] = i * 10 + j
        array.set(i, j, i * 10 + j)

    count = 0
    array.forEach (v, x, y) ->
      v.should.equal a[x][y]
      count++

    count.should.equal width * height

  it "should retrieve the last value set() at the given coordinates with at()", ->
    testValues = [
      [2, 4, 1]
      [0, 0, 48]
      [9, 3, "test"]
      [8,9, [1]]
      [8, 9, 42]
    ]
    for v in testValues
      array.set v...
      array.at(v[0], v[1]).should.equal v[2]
