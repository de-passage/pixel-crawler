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
#            of the acting Entity (2 steps)               |
#                       |_________________________________|
#
# Actions:
#   Actions themselves are responsible for checking that the actor 
#   can actually do what it is trying to. 

inRange = (xs, ys, xd, yd, range) ->
  # Computing the squared distance to destination and comparing it to the squared range
  # to determine if the destination can be reached
  hDist = xd - xs
  vDist = yd - ys
  sHD = hDist * hDist
  sVD = vDist * vDist
  sR = range * range
  sR >= sHD + sVD

spellList = require "./spells.coffee"

actions =
  pass: ->
    # Passing does nothing
    
  # This is wrong, doesn't check for obstacles. Should use A* and check number of steps.
  move: (map, x, y) ->
    try
      mvSpeed = this.property("movement")
    catch
      throw new Error "This entity (ID: #{@id()}, at (#{@x}, #{@y})) cannot move (no 'movement' property)"

    # Check the collision property of the terrain at {x, y} and every entity on the tile, and
    # save in `collide` the conjunction of all those booleans, indicating wheter the entity collide
    # (and therefore cannot enter) the target tile
    collide = [map.terrainAt(x,y)].concat(map.entitiesAt(x,y)).reduce(((acc, ent) => acc || ent.property("collision", this)), false)
    if collide
      throw new Error "This entity cannot move through (#{x}, #{y})"

    if inRange(@x, @y, x, y, mvSpeed)
      map.moveEntity this, x, y
    else
      throw new Error "This entity's movement speed (#{mvSpeed}) doesn't allow it to travel to (#{x}, #{y})"

  attack: (map, x, y, targetID) ->
    target = map.findEntityAt x, y, (e) -> e.id() == targetID
    range = @property("range")
    if inRange(@x, @y, x, y, range)
      target.react("hit", @property("damage"))
    else
      throw new Error "Target #{targetID} (#{@x}, #{@y}) of #{@id} (#{x}, #{y}) is out of range #{range}."

  spell: (map, x, y, spell, target) ->
    spells = @property("spells")
    throw new Error "`#{spell}` is not a spell" unless spellList[spell]?
    throw new Error "This entity (id: #{@id()}) cannot cast `#{spell}`" unless spell in spells

    spellEntity = spellList[spell]

    cost = spellEntity.property("cost")
    range = spellEntity.property("range")
    cooldown = spellEntity.property("cooldown")

    throw Error "Spell #{spell}, cast from (#{@x}, #{@y}) to (#{x}, #{y}) is out of range (#{range})." unless inRange(@x, @y, x, y, range)

    spellEntity.react("effect", @)


module.exports = actions
