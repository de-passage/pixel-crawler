require("chai").should()
Entity = require "../src/models/entity.coffee"

describe "Entity", ->

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
        accessText: (caller, property) -> caller.property(property)[1]

  it "should have properties if added", ->
    [ok, r1] = entityWithProperties.property "property1"
    [ok2, r2] = entityWithProperties.property "property2"
    ok.should.equal true
    ok2.should.equal true
    r1.should.equal("something")
    r2.should.equal("something else")

  it "shouldn't have properties if not added", ->
    [ok1, r1] = entityWithReactions.property "property1"
    [ok2, r2] = entityWithProperties.property "property3"
    [ok3, r3] = emptyEntity.property "property3"
    for v in [ok1, ok2, ok3]
      v.should.equal false
    for v in [r1, r2, r3]
      (typeof v).should.equal "undefined"

  it "should not share properties between entities", ->
    [_, r1] = entityWithProperties.property "property2"
    [_, r2] = entityWithBoth.property "property2"
    r1.should.equal "something else"
    r2.should.equal "something"

  it "should keep its inner state inaccessible", ->
    publicInterface = [ "property", "react" ]
    objects = [entityWithBoth, entityWithReactions, entityWithProperties, emptyEntity]
    count = 0
    for entity in objects
      for k, v of entity
        count++
        (k in publicInterface).should.equal true
    count.should.equal publicInterface.length * objects.length
    
  it "should have reactions if added", ->
    [ok1, r1] = entityWithReactions.react "reaction1"
    [ok2, r2] = entityWithBoth.react "reaction3"
    ok1.should.equal true
    ok2.should.equal true
    r1.should.equal "react"
    r2.should.equal "another reaction"

  it "shouldn't have reactions if not added", ->
    [ok1, r1] = entityWithProperties.react "reaction1"
    [ok2, r2] = entityWithReactions.react "property3"
    [ok3, r3] = emptyEntity.react "property3"
    for v in [ok1, ok2, ok3]
      v.should.equal false
    for v in [r1, r2, r3]
      (typeof v).should.equal "undefined"

  it "should not share reactions between entities", ->
    [_, r1] = entityWithReactions.react "reaction2"
    [_, r2] = entityWithBoth.react "reaction2"
    r1.should.equal "react to sth else"
    r2.should.equal "react"

  it "should be possible to access properties from reactions", ->
    [ok, r] = entityWithBoth.react "accessText", "text"
    ok.should.equal true
    r.should.equal "empty"

