require("chai").should()
Entity = require "../src/models/entity.coffee"

describe "Entity", ->

  publicInterface = [ "property", "react" ]

  emptyEntity = null
  entityWithProperties = null
  entityWithReactions = null
  entityWithBoth = null
  beforeEach ->
    emptyEntity = new Entity
    entityWithProperties = new Entity
      properties:
        property1: "something"
        property2: "something else"
    entityWithReactions = new Entity
      reactions:
        reaction1: -> "react"
        reaction2: -> "react to sth else"
    entityWithBoth = new Entity
      properties:
        property2: "something"
        property3: "something else"
        text: "empty"
      reactions:
        reaction2: -> "react"
        reaction3: -> "another reaction"
        accessText: (caller, property) -> caller.property(property)
        setText: (caller, value) -> caller.setProperty("text", "something")

  it "should have properties if added", ->
    r1 = entityWithProperties.property "property1"
    r2 = entityWithProperties.property "property2"
    r1.should.equal("something")
    r2.should.equal("something else")

  it "shouldn't have properties if not added", ->
    ( -> entityWithReactions.property "property1").should.throw(Error)
    ( -> entityWithProperties.property "property3").should.throw(Error)
    ( -> emptyEntity.property "property3").should.throw(Error)

  it "should not share properties between entities", ->
    r1 = entityWithProperties.property "property2"
    r2 = entityWithBoth.property "property2"
    r1.should.equal "something else"
    r2.should.equal "something"

  it "should keep its inner state inaccessible", ->
    objects = [entityWithBoth, entityWithReactions, entityWithProperties, emptyEntity]
    count = 0
    for entity in objects
      for k, v of entity
        count++
        (k in publicInterface).should.equal true
    count.should.equal publicInterface.length * objects.length
    
  it "should have reactions if added", ->
    r1 = entityWithReactions.react "reaction1"
    r2 = entityWithBoth.react "reaction3"
    r1.should.equal "react"
    r2.should.equal "another reaction"

  it "shouldn't have reactions if not added", ->
    ( -> entityWithProperties.react "reaction1").should.throw(Error)
    ( -> entityWithReactions.react "property3").should.throw(Error)
    ( -> emptyEntity.react "property3").should.throw(Error)

  it "should not share reactions between entities", ->
    r1 = entityWithReactions.react "reaction2"
    r2 = entityWithBoth.react "reaction2"
    r1.should.equal "react to sth else"
    r2.should.equal "react"

  it "should be possible to access properties from reactions", ->
    r = entityWithBoth.react "accessText", "text"
    r.should.equal "empty"

  it "should be possible to modify properties from reactions", ->
    entityWithBoth.react "setText"
    entityWithBoth.property("text").should.equal "something"

