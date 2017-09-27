Map = require "../src/models/map.coffee"
Tile = require "../src/models/tile.coffee"
Entity = require "../src/models/entity.coffee"
chai = require "chai"
chai.should()

describe "Map", ->

  map = null

  beforeEach ->
    map = new Map 10, 10, (x, y) ->
      new Entity
        properties:
          value: x * y

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

  ["width", "height"].forEach (dim, idx) ->
    it "should expose its #{dim} through the #{dim}() method", ->
      for vals in [ [10, 10], [3, 50], [34, 9]]
        map = new Map vals..., -> null
        map[dim]().should.equal vals[idx]
    

  it "should return the correct terrain on terrainAt", ->
    
    
