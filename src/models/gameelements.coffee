# Stuffs that can be displayed on screen with their basic behaviour regarding character vision
# seethrough: Indicates whether or not the element blocks vision
# fog: Indicates whether or not the element is visible throught the fog of war
# color: color of the tile on screen
gameElements=
  wall:
    seethrough: false
    color: "grey"
    fog: true
  character:
    seethrough: true
    color: "red"
    fog: false
  item:
    seethrough: false
    fog: true
    color: "yellow"
# end gameElement


module.exports = gameElements
