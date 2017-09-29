# Defines what an entity can do to another
# Concretely makes the link between reactions of two entities
#
# The flow of the game is as follow: 
#
#   The game logic controller decides who gets to act <----
#                       |                                 |
#                       V                                 |
#        The game logic hands out the                     |
#    action registration forms (callbacks)                |
#                       |                                 |
#                       V                                 |
# The selected entities register one action each          |
#                       |                                 |
#                       V                                 |
#        The game controller executes                     |
#         every action in the context                     |
#            of the acting Entity                         |
#                       |_________________________________|
#
#   Actions themselves are responsible for checking that the actor 
#   can actually do what it is trying to
#

actions =
  # This is wrong, doesn't check for obstacles. Should use A* and check number of steps.
  move: (map, x, y) ->
    mvSpeed = null
    try
      mvSpeed = this.property("movement")
    catch
      throw Error "This entity (ID: #{@id}, at (#{@x}, #{@y})) cannot move"

    # Check the collision property of the terrain at {x, y} and every entity on the tile, and
    # save in `collide` the conjunction of all those booleans, indicating wheter the entity collide
    # (and therefore cannot enter) the target tile
    collide = [map.terrainAt(x,y)].concat(map.entitiesAt(x,y)).reduce(((acc, ent) -> acc || ent.property("collision", this)), false)
    if collide
      throw Error "This entity cannot move through (#{x}, #{y})"

    # Computing the squared distance to destination and comparing it to the squared movement speed
    # to determine if the destination can be reached in 1 turn (faster than computing a square root)
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

  attack: (map, x, y, target) ->

  spell: (map, x, y, target) ->


module.exports = actions
