Map = require "../src/models/map.coffee"
Tile = require "../src/models/tile.coffee"
Entity = require "../src/models/entity.coffee"
chai = require "chai"
chai.should()

map = null

randCoord = ->
    randInt = (dim) -> Math.floor Math.random(0, map[dim]())
    [randInt("width"), randInt("height")]

describe "Map", ->
  beforeEach "should be constructible", ->
    map = new Map 10, 10, (x, y) ->
      new Tile new Entity
        properties:
          value: x * 10 + y

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
    it "should expose its #{dim} as a method of the same name", ->
      for vals in [ [10, 10], [3, 50], [34, 9]]
        map = new Map vals..., -> null
        map[dim]().should.equal vals[idx]

  it "should return the correct terrain on terrainAt", ->
    for i in [0...map.width()]
      for j in [0...map.height()]
        map.terrainAt(i, j).property("value").should.equal i * 10 + j

  it "should change the terrain at given coordinates on setTerrainAt()", ->
    newTerrain = new Entity properties: name: "ground"
    coords = randCoord()
    map.setTerrainAt coords..., newTerrain
    t = map.terrainAt coords...
    t.property("name").should.equal newTerrain.property("name")

  it "should return the correct entity list on entitiesAt", ->
    props = [
      { properties:
        name: "monster" },
      properties:
        name: "character"
    ]
    coords = randCoord()
    ret = map.entitiesAt(coords...)
    Array.isArray(ret).should.equal true
    ret.length.should.equal 0

    for p in props
      entity = new Entity p
      map.addEntityAt coords..., entity

    ret = map.entitiesAt(coords...)
    Array.isArray(ret).should.equal true
    ret.length.should.equal 2
    for v, i in props
      ret[i].property("name").should.equal v.properties.name


  describe "#proxy()", ->
    authorizedKeys = [
      "width"
      "height"
      "terrainAt"
      "entitiesAt"
    ]
    proxy = null

    beforeEach ->
      proxy = map.proxy()

    it "should only expose the necessary keys to the user (#{authorizedKeys.join(", ")})", ->
      for k in Object.keys proxy
        (k in authorizedKeys).should.equal true
      Object.keys(proxy).length.should.equal authorizedKeys.length

    ["width", "height"].forEach (name) ->
      describe "##{name}()", ->
        it "should equal the original map.#{name}() value", ->
          proxy[name]().should.equal map[name]()

    describe "#entitiesAt()", ->
      it "should return an array of entities for which only the id and property elements are available", ->
        props = [
          { properties:
            name: "monster" },
          properties:
            name: "character"
        ]
        coords = randCoord()
        ret = proxy.entitiesAt(coords...)
        Array.isArray(ret).should.equal true
        ret.length.should.equal 0

        for p in props
          entity = new Entity p
          map.addEntityAt coords..., entity

        ret = proxy.entitiesAt(coords...)
        Array.isArray(ret).should.equal true
        ret.length.should.equal 2
        for v, i in props
          for k in Object.keys ret[i]
            (k in ["id", "property"]).should.equal true
          ret[i].property("name").should.equal v.properties.name

    describe "#terrainAt()", ->
      it "should return an entity for which only the id and property elements are available", ->
        for i in [0...proxy.width()]
          for j in [0...proxy.height()]
            t = proxy.terrainAt i, j
            for k in Object.keys t
              (k in ["id", "property"]).should.equal true
            t.property("value").should.equal i * 10 + j



