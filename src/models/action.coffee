# Defines what an entity can do to another
# Concretely makes the link between reactions of two entities
#
# The flow of the game is as follow: 
#
#   The game controller decides who gets to act <----
#                       |                           |
#                       V                           |
#        The game controller hands out the          |
#    action registration forms (callbacks)          |
#                       |                           |
#                       V                           |
# The selected entities register one action each    |
#                       |                           |
#                       V                           |
#        The game controller executes               |
#     every action, linking to the proper           |
#                    targets                        |
#                       |___________________________|
#
#

actions =
  # This is wrong, doesn't check for obstacles. Should use A* and check number of steps.
  move: (map, x, y) ->
    mvSpeed = null
    try
      mvSpeed = this.property("movement")
    catch
      throw Error "This entity (ID: #{@id}, at (#{@x}, #{@y})) cannot move"
    hDist = x - @x
    vDist = y - @y
    sHD = hDist * hDist
    sVD = vDist * vDist
    sMV = mvSpeed * mvSpeed
    inRange = sMV >= sHD + sVD
    if inRange
      map.moveEntity this, x, y
    else
      throw Error "This entity's movement speed (#{mvSpeed}) doesn't allow it to travel to (#{x}, #{y})"


module.exports = actions
