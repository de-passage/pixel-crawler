Map = require "../src/models/map.coffee"
Tile = require "../src/models/tile.coffee"
Entity = require "../src/models/entity.coffee"
chai = require "chai"
chai.should()

describe "Map", ->

  map = new Map 10, 10

  beforeEach ->

  it "should be constructible with an initialization function", ->
    map = new Map 10, 10, (x, y) ->
      entity = new Entity
        properties:
          x: x
          y: y
      new Tile entity

    for i in [0...10]
      for j in [0...10]
        t = map.terrainAt(i, j)
        t.property "x"
        .should.equal i
        t.property "y"
        .should.equal j

    

  it "should return the correct terrain on terrainAt", ->
