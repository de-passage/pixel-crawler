Map = require "../src/models/map.coffee"
Tile = require "../src/models/tile.coffee"
Entity = require "../src/models/entity.coffee"
chai = require "chai"
chai.should()

map = null

randCoord = ->
    randInt = (dim) -> Math.floor(Math.random() * map[dim]())
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

  describe "#addEntity()", ->
    values =  [ [[3, 4], "entity"]
      [[5,4], "entity2"]
    ]
    beforeEach "trying to call", ->
      for v in values
        map.addEntityAt v[0]..., new Entity properties: name: v[1]

    it "should add the entity to the correct tile", ->
      for v in values
        e = map.entitiesAt v[0]...
        e.length.should.equal 1
        e[0].property("name").should.equal v[1]

    it "should add x and y attributes to the entity", ->
      for v in values
        [x, y] = v[0]
        e = map.entitiesAt(x, y)[0]
        (typeof e.x).should.not.equal "undefined"
        e.x.should.equal x
        (typeof e.y).should.not.equal "undefined"
        e.y.should.equal y


  describe "#entitiesAt()", ->
    it "should return an empty list if there are no entities there", ->
      for i in [0...map.width()]
        for j in [0...map.height()]
          ret = map.entitiesAt i, j
          Array.isArray(ret).should.equal true
          ret.length.should.equal 0

    it "should return the correct entity list if entities are present", ->
      props = [
        { properties:
          name: "monster" },
        properties:
          name: "character"
      ]
      coords = randCoord()
      ret = map.entitiesAt(coords...)
      for p in props
        entity = new Entity p
        map.addEntityAt coords..., entity

      ret = map.entitiesAt(coords...)
      Array.isArray(ret).should.equal true
      ret.length.should.equal 2
      for v, i in props
        ret[i].property("name").should.equal v.properties.name


  describe "#moveEntity()", ->

    entity = new Entity properties: name: "character"
    startCoords = null
    randCoordDifFrom = (s) ->
      n = randCoord()
      while (n[0] == s[0]) && (n[1] == s[1])
        n = randCoord()
      return n


    beforeEach "trying to call moveEntity()", ->
      startCoords = randCoord()
      map.addEntityAt startCoords..., entity
      entity.x.should.equal startCoords[0]
      entity.y.should.equal startCoords[1]

    it "should remove the entity from it's starting position", ->
      map.moveEntity entity, 0, 0
      t = map.entitiesAt startCoords...
      Array.isArray(t).should.equal true
      t.length.should.equal 0

    it "should add the entity to the destination", ->
      destCoords = randCoordDifFrom startCoords
      map.moveEntity entity, destCoords...
      t = map.entitiesAt destCoords...
      Array.isArray(t).should.equal true
      t.length.should.equal 1
      t[0].property("name").should.equal "character"

    it "should update the entity's coordinates", ->
      destCoords = randCoordDifFrom startCoords
      map.moveEntity entity, destCoords...
      t = map.entitiesAt destCoords...
      Array.isArray(t).should.equal true
      t.length.should.equal 1
      t[0].x.should.equal destCoords[0]
      t[0].y.should.equal destCoords[1]

  describe "#playableEntities", ->
    entity = new Entity properties: name: "character"

    it "should be directly accessible", ->
      Array.isArray(map.playableEntities).should.equal true

    it "should obtain new elements on addPlayableEntityAt()", ->
      map.playableEntities.length.should.equal 0
      coords = randCoord()
      map.addPlayableEntityAt coords..., entity
      map.playableEntities.length.should.equal 1
      map.playableEntities[0].property("name").should.equal "character"

    it "should update the map tiles on addPlayableEntityAt()", ->
      coords = randCoord()
      map.entitiesAt(coords...).length.should.equal 0
      map.addPlayableEntityAt coords..., entity
      map.entitiesAt(coords...).length.should.equal 1
      map.entitiesAt(coords...)[0].property("name").should.equal "character"

    it "should lose elements on removePlayableEntity()", ->
      coords = randCoord()
      map.addPlayableEntityAt coords..., entity
      map.removePlayableEntity (e) -> e.id == entity.id
      map.playableEntities.length.should.equal 0

    it "should update the map tiles on removePlayableEntity()", ->
      coords = randCoord()
      map.addPlayableEntityAt coords..., entity
      map.removePlayableEntity (e) -> e.id == entity.id
      map.entitiesAt(coords...).length.should.equal 0


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
      it "should return an empty array if no entities are present", ->
        for i in [0...map.width()]
          for j in [0...map.height()]
            ret = map.entitiesAt i, j
            Array.isArray(ret).should.equal true
            ret.length.should.equal 0

      it "should return an array of entities for which only the id and property elements are available", ->
        props = [
          { properties:
            name: "monster" },
          properties:
            name: "character"
        ]
        coords = randCoord()
        ret = proxy.entitiesAt(coords...)
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



