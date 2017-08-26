#
# Defines general properties of game entities
# Act as a data store where inner data can only be mutated through
# predefined accessors called reactions
#
class Entity
  @count = 0

  # Create an entity from the pieces of data passed to it
  constructor: (entityData...) ->

    @id = Entity.count
    Entity.count++

    reactions = {}
    properties = {}
    validators = {}

    # ###################
    # Utility functions #
    # ###################

    # Validation for property setting.
    validate = (name, prev, value) =>
      if validators[name]?
        value = validators[name](prev, value, @property)
      value

    # Sets a property according to the validation process
    setProperty = (name, value) ->
      prev = properties[name]
      #throw new Error "Invalid assignment: property #{name} doesn't exist" unless prev?
      throw new Error "Invalid assignment: forbidden to set a property (#{name}) to undefined"  if typeof value == "undefined"
      properties[name] = validate(name, prev, value)
      

    # ###################
    # Constructor logic #
    # ###################

    # Actually adds elements to the object
    for data in entityData
      if data.validators?
        for k, v of data.validators
          throw new Error "Validator for #{k} must be a function (got a #{typeof v})" if typeof v isnt "function"
          validators[k] = v
      if data.reactions?
        for k, v of data.reactions
          throw new Error "Reaction #{k} is not a function (is #{v})" if typeof v isnt "function"
          reactions[k] = v
      if data.properties?
        for k, v of data.properties
          properties[k] = v
          #setProperty k, v
    
    # #########################
    # Entity member functions #
    # #########################

    # Returns the property if it exists.
    @property = (property) ->
      if typeof (p = properties[property]) isnt "undefined"
        return p
      throw new Error "Invalid reference: property #{property} is not defined"


    # Calls for a reaction to the event "message" from source "caller" with arguments "args"
    # If the reaction is a function, passes the caller and args as arguments and call the callback
    # with the result of the function.
    # If the reaction is a value, then calls the callback with the value.
    # Returns false and do nothing if the reaction is undefined, returns true otherwise
    @react = (message, args...) ->
      f = reactions[message]
      throw new Error "Invalid reference: reaction #{message} is not defined" unless f?
      f.apply null, [{property: @property, react: @react, setProperty: setProperty}, args...]
  
  # CONSTRUCTOR #

# end class Entity

module.exports = Entity
