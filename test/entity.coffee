require("chai").should()
Entity = require "../src/models/entity.coffee"

describe "Entity", ->

  publicInterface = [ "property", "react", "id", "hasProperty", "hasReaction", "protected" ]

  emptyEntity = null
  entityWithProperties = null
  entityWithReactions = null
  entityWithBoth = null
  entityWithValidators = null
  entityWithComputedProperties = null
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
        accessText: (property) -> @property(property)
        setText: (value) -> @setProperty("text", "something")
    entityWithValidators = new Entity
      properties:
        value: 0
      reactions:
        setValue: (value) -> @setProperty "value", value
      validators:
        value: (prev, next) -> if prev > next then prev else next
    entityWithComputedProperties = new Entity
      properties:
        value1: 42
        value2: 24
        sum: -> @property("value1") +  @property("value2")
      reactions:
        invalidReaction: ->
          @setProperty "sum", 0


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

  it "should have an unique ID", ->
    array = [emptyEntity, entityWithReactions, entityWithProperties, entityWithBoth]
    for i in [0...4]
      for j in [(i + 1)...4]
        (array[i].id != array[j].id).should.equal(true)

  it "should apply validators on setProperty()", ->
    entityWithValidators.react "setValue", 10
    entityWithValidators.property("value").should.equal 10
    entityWithValidators.react "setValue", 5
    entityWithValidators.property("value").should.equal 10

  it "should check whether a property is defined with hasProperty()", ->
    entityWithProperties.hasProperty("property1").should.equal true
    entityWithProperties.hasProperty("property3").should.equal false

  it "should check whether a reaction is defined with hasReaction()", ->
    entityWithReactions.hasReaction("reaction1").should.equal true
    entityWithReactions.hasReaction("reaction3").should.equal false

  it "should allow functions as properties (computed properties)", ->
    entityWithComputedProperties.property("sum").should.equal 42 + 24

  it "should throw if setProperty is called on a computed property", ->
    ( -> entityWithComputedProperties.react("invalidReaction") ).should.throw Error

  it "should throw if a validator is given for a computed property", ->
    ( -> new Entity properties: { computed: -> }, validators: { computed: -> } ).should.throw Error
    ( -> new Entity validators: { computed: -> }, properties: { computed: -> }).should.throw Error

  describe "#protected", ->
    proxy = null
    beforeEach ->
      proxy = entityWithBoth.protected

    it "should expose its parent's #property()", ->
      proxy.property("text").should.equal "empty"

    [["Property", "property2", "property1"], ["Reaction", "reaction2", "reaction1"]].forEach (pair) ->
      it "should expose its parent's #has#{pair[0]}()", ->
        proxy["has#{pair[0]}"](pair[1]).should.equal true
        proxy["has#{pair[0]}"](pair[2]).should.equal false

    it "should hide its parent's #react()", ->
      (typeof proxy.react).should.equal "undefined"



