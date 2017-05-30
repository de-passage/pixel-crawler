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

module.exports = Entity
