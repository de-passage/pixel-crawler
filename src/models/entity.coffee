#
# Defines general properties of game entities
# Act as a data store where inner data can only be mutated through
# predefined accessors called reactions
#
class Entity

  # Create an entity from the pieces of data passed to it
  constructor: (entityData...) ->
    reactions = {}
    properties = {}
    validators = {}
    for data in entityData
      if data.properties?
        for k, v of data.properties
          properties[k] = v
      if data.reactions?
        for k, v of data.reactions
          throw "Reaction #{k} is not a function (is #{v})" if typeof v isnt "function"
          reactions[k] = v
      if data.validators?
        for k, v of data.validators
          throw "Validator for #{k} must be a function (got #{v})" if typeof v isnt "function"
          validators[k] = v

    # Validation for property setting.
    validate = (name, value) ->
      if validators[name]?
        value = validators[name](properties[name], value)
      
    
    #
    # The following are actually part of the constructor to provide access to the private members

    # Returns the property if it exists.
    @property = (property) ->
      if (p = properties[property])?
        return [true, p]
      return [false]


    # Calls for a reaction to the event "message" from source "caller" with arguments "args"
    # If the reaction is a function, passes the caller and args as arguments and call the callback
    # with the result of the function.
    # If the reaction is a value, then calls the callback with the value.
    # Returns false and do nothing if the reaction is undefined, returns true otherwise
    @react = (message, args, callback) ->
      f = reactions[message]
      return [false] unless f?
      if typeof args == "function" and !callback?
        callback = args
        args = []
      else if not Array.isArray args
        args = [args]
      [ true, f.apply null, [{property: @property, react: @react, setProperty: (name, value) => properties[name] = value}, args...] ]

# end class Entity

module.exports = Entity
