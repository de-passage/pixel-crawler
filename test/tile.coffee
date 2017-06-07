require("chai").should()

Tile = require("../src/models/tile.coffee")
Entity = require "../src/models/entity.coffee"

describe "Tiles", ->

  wall = new Entity
    properties:
      name: "wall"
      id: 0
  monster = new Entity
    properties:
      name: "monster"
      id: 1
  character = new Entity
    properties:
      name: "character"
      id: 2

  it "Should hold a terrain and entities", ->
    t1 = new Tile wall, monster, character
    t1.terrain().property("name").should.equal "wall"
    t1.terrain().property("id").should.equal 0
    t1.entities.length.should.equal 2

  it "should be possible to add entities", ->
    t2 = new Tile wall
    t2.addEntity monster
    t2.entities.length.should.equal 1
    t2.addEntity character
    t2.entities.length.should.equal 2


