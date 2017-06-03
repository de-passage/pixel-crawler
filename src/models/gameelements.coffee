# Stuffs that can be displayed on screen with their basic behaviour regarding character vision
# seethrough: Indicates whether or not the element blocks vision
# fog: Indicates whether or not the element is visible throught the fog of war
# color: color of the tile on screen

gameElements=

  wall:
    properties:
      seethrough: false
      color: "grey"
      fog: true
    reactions:
      collision: -> false


  emptySpace:
    properties:
      seethrough: true
      color: "white"
      fog: "true"
    reactions:
      collision: -> true

  character:
    properties:
      seethrough: true
      color: "red"
      fog: false
      actions: ["move"]
      health: 0
      maxHealth: 0
      resistances: []
      traits: []
    reactions:
      collision: (self, source, map) ->
        self.react "defense", source.react "attack"
      attack: (self, source) -> {}
      defense: (self, attack) ->
        for type, dmg of attack
          self.properties("resistances")
      play: (self, game) ->

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
      seethrough: false
      fog: true
      color: "yellow"
    reactions:
      collision: -> true

# end gameElements


module.exports = gameElements
