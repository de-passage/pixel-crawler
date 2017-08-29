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

  it "should be possible to find entities with a filter function", ->
    t2 = new Tile wall
    t2.addEntity monster
    t2.addEntity character

    r1 = t2.findEntities -> true
    r1.length.should.equal 2
    r1[0].property("name").should.equal "monster"
    r1[1].property("name").should.equal "character"

    r2 = t2.findEntities (ent) -> ent.property("name") == "character"
    r2.length.should.equal 1
    r2[0].property("name").should.equal "character"

    r3 = t2.findEntities (ent) -> false
    r3.length.should.equal 0

  it "should be possible to find a single entity with a filter function", ->
    t = new Tile wall
    t.addEntity monster
    t.addEntity character

    t.findEntity (ent) -> ent.property("id") == 1
    .property "name"
    .should.equal "monster"

    t.findEntity (ent) -> ent.property("name") == "character"
    .property "id"
    .should.equal 2

    (t.findEntity(-> false) == null).should.equal true

  it "should return the most recently added entity or the terrain if no entity is present with topLevelEntity()", ->
    t = new Tile wall
    t.topLevelEntity().property "name"
    .should.equal "wall"

    t.addEntity monster
    t.topLevelEntity().property "name"
    .should.equal "monster"

    t.addEntity character
    t.topLevelEntity().property "name"
    .should.equal "character"

  it "should remove entities matching a filter function with removeEntity()", ->
    t = new Tile wall
    t.addEntity monster
    t.addEntity character

    t.entities.length.should.equal 2
    t.entities[0].property "name"
    .should.equal "monster"
    t.removeEntity (ent) -> ent.property("name") == "monster"
    t.entities.length.should.equal 1
    t.entities[0].property "name"
    .should.equal "character"

