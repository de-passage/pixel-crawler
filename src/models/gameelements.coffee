Entity = require "./entity.coffee"

# Helper function to determine whether or not a given entity has a given trait or not

hasTrait = (target, trait) ->
  target.hasProperty("traits") and trait in target.property("traits")

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
    effet: null

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
    #actions: ["attack"]
    maxHealth: 0
    health: 0
    resistances:
      normal: 0
      fire: 0
      darkness: 0
    traits: []
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
        1
    dead: -> @property("health") == 0

  reactions:
    hit: (damage) ->
      res = @property "resistances"
      total = 0
      for type, qty of damage
        total += Math.round (res[type] || 0) * qty
      h = @setProperty "health", @property("health") - total

  validators:
    health: (prev, next, props) ->
      if next > @properties("maxHealth")
        @properties("maxHealth")
      else if next < 0
        0
      else next
    maxHealth: (prev, next) -> if next < 0 then 0 else next
#      actions: (prev, next) ->
#        unless Array.isArray(prev)
#          prev = [prev]
#        unless Array.isArray(next)
#          next = [next]
#        for e in next
#          unless prev.indexOf(e) != -1
#            prev.push e
#        prev

item =
  properties:
    seethrough: true
    fog: true
    color: "yellow"
    collision: false

gameElements= { item, character, weapon, emptySpace, wall, spell }



module.exports = gameElements
