# Stuffs that can be displayed on screen with their basic behaviour regarding character vision
# seethrough: Indicates whether or not the element blocks vision
# fog: Indicates whether or not the element is visible throught the fog of war
# color: color of the tile on screen

# Helper function to determine whether or not a given entity has a given trait or not

hasTrait = (target, trait) ->
  target.hasProperty("traits") and trait in target.property("traits")

gameElements=

  wall:
    properties:
      seethrough: false
      color: "grey"
      fog: true
      collision: (target) -> !hasTrait(target, "incorporeal")

  emptySpace:
    properties:
      seethrough: true
      color: "white"
      fog: "true"
      collision: false

  character:
    properties:
      seethrough: true
      color: "red"
      fog: false
      actions: ["move"]
      maxHealth: 0
      health: 0
      resistances: []
      traits: []
      collision: true
      movement: 1

    validators:
      health: (prev, next, props) ->
        if next > props["maxHealth"]
          props["maxHealth"]
        else if next < 0
          0
        else next
      maxHealth: (prev, next) -> if next < 0 then 0 else next
      actions: (prev, next) ->
        unless Array.isArray(prev)
          prev = [prev]
        unless Array.isArray(next)
          next = [next]
        for e in next
          unless prev.indexOf(e) != -1
            prev.push e
        prev

  item:
    properties:
      seethrough: true
      fog: true
      color: "yellow"
      collision: false

# end gameElements


module.exports = gameElements
