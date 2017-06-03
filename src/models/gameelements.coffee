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
      collision: (source) ->
        false
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
    reactions:
      collision: () ->
    validators:
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
      turn: ->
# end gameElement


module.exports = gameElements
