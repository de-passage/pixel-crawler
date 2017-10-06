Entity = require "./entity.coffee"

# Helper function to determine whether or not a given entity has a given trait or not

hasTrait = (target, trait) ->
  target.hasProperty("traits") and trait in target.property("traits")


addToArray = (prop, element) ->
    array = @property prop
    array.push element
    @setProperty prop, array

removeFromArray = (prop, element) ->
    array = @property prop
    idx = array.indexOf element
    if idx != -1
      array.splice idx, 1
      @setProperty prop, array

# seethrough: Indicates whether or not the element blocks vision
# fog: Indicates whether or not the element is visible throught the fog of war
# color: color of the tile on screen

wall =
  properties:
    seethrough: false
    color: "grey"
    fog: true
    collision: (target) -> !hasTrait(target, "incorporeal")

emptySpace =
  properties:
    seethrough: true
    color: "white"
    fog: true
    collision: false

weapon =
  properties:
    range: 1
    damage:
      normal: 1
    effet: (args) ->

spell =
  properties:
    cost: 0
    cooldown: 0
    area: (args) -> []
  reactions:
    effect: (args) ->

character =
  properties:
    weapon: new Entity weapon
    seethrough: true
    color: "red"
    fog: false
    maxHealth: 0
    health: 0
    resistances:
      normal: 0
      fire: 0
      darkness: 0
    traits: []
    spells: [] # strings representing the name only
    collision: -> @property("health") > 0
    movement: 1
    range: ->
      if w = @property("weapon")
        w.property("range")
      else
        1
    damage: ->
      if w = @property("weapon")
        w.property("damage")
      else
        normal: 1
    dead: -> @property("health") == 0

  reactions:
    hit: (damage) ->
      res = @property "resistances"
      total = 0
      for type, qty of damage
        total += Math.round (1 - (res[type] || 0)) * qty
      h = @setProperty "health", @property("health") - total

    heal: (qty) ->
      @setProperty "health", @property("health") + qty

    addTrait: (element) -> addToArray.call(this, "traits", element)
    removeTrait: (element) -> removeFromArray.call(this, "traits", element)
    addSpell: (element) -> addToArray.call(this, "spells", element)
    removeSpell: (element) -> removeFromArray.call(this, "spells", element)
    changeWeapon: (weapon) -> @setProperty "weapon", weapon

  validators:
    health: (prev, next, props) ->
      if next > @property("maxHealth")
        @property("maxHealth")
      else if next < 0
        0
      else next
    maxHealth: (prev, next) -> if next < 0 then 0 else next

item =
  properties:
    seethrough: true
    fog: true
    color: "yellow"
    collision: false

gameElements = { item, character, weapon, emptySpace, wall, spell }



module.exports = gameElements
