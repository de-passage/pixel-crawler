#GameElements = require "../src/models/gameelements.coffee"
Constructor = require "../src/models/entityconstructors.coffee"

chai = require "chai"
chai.should()

describe "Game Elements", ->

  describe "Character", ->

    character = new Constructor.PlayableCharacter null, properties: { health: 20, maxHealth: 20, resistances: { normal: 0, fire: 0.1, darkness: 0.5 } }
    monster = new Constructor.PlayableCharacter null, properties: { health: 10, maxHealth: 10 , resistances: normal: 0.33 }

    sword = new Constructor.Weapon properties: damage: normal: 3
    staff = new Constructor.Weapon properties: damage: { normal: 1, darkness: 2 }

    it "should lose health when hit", ->
      character.property("health").should.equal 20
      character.react "hit", normal: 3
      character.property "health"
      .should.equal 17

    it "should gain health when healed", ->
      character.react "heal", 5
      character.property "health"
      .should.equal 20

    it "should be able to change weapons", ->
      character.react "changeWeapon", sword
      character.property("damage").normal.should.equal 3
      monster.react "changeWeapon", staff
      md = monster.property "damage"
      md.normal.should.equal 1
      md.darkness.should.equal 2

    it "should apply resistance when hit", ->
      character.react "hit", monster.property "damage"
      character.property("health").should.equal 18

