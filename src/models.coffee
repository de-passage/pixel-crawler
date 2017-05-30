# ############################
#       Models               #
# ############################

# Stuffs that can be displayed on screen with their basic behaviour regarding character vision
# seethrough: Indicates whether or not the element blocks vision
# fog: Indicates whether or not the element is visible throught the fog of war
# color: color of the tile on screen
module.exports =
  gameElements:
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

# General entity class
# Defines general properties of game entities
class Entity
  reactions = {}
  # Create an entity from the pieces of data passed to it
  constructor: (entityData...) ->
    for data in entityData
      reactions[k] = v for k, v in data when k not in ["turn"]

  # Calls for a reaction to the event "messaage" from source "caller" with arguments "args"
  # If the reaction is a function, passes the caller and args as arguments and call the callback
  # with the result of the function.
  # If the reaction is a value, then calls the callback with the value.
  # Returns false and do nothing if the reaction is undefined, returns true otherwise
  react: (message, caller, args, callback) ->
    f = reactions[message]
    return false unless f?
    callback = args if typeof args == "function" and !callback?
    if typeof f == "function"
      callback f.apply null, [caller, args...]
    else
      callback f
    return true

# end class Entity

# Defines the content of a single tile on the game map
class Tile
  constructor: (ter, es...) ->
    terrain = ter
    entities = es
  terrain: (t) ->
    if t? then terrain = t else terrain
  addEntity: (en) ->
    entities.push en
  removeEntity: (callback) ->
    i = idx for val, idx in entities when callback(val)
    entities.splice i, 1 if i?
# end class Tile

# Utility class holding a 2d array
class Array2D
  constructor: (@width, @height) ->
    array = new Array(@width * @height)
  at: (x, y) ->
    array[ x + y * @width ]
  set: (x, y, v) ->
    array[ x + y * @width ] = v
  forEach: (callback) ->
    for x in [0...@width]
      for y in [0...@height]
        callback array[ x + y * @width ], x, y
# end class Array2D

