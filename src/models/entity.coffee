#
# Defines general properties of game entities
# Act as a data store where inner data can only be mutated through
# predefined accessors called reactions
#
class Entity
  @count = 0

  # Create an entity from the pieces of data passed to it
  constructor: (entityData...) ->

    id = Entity.count
    @id = -> id
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
        value = validators[name].call(@protected, prev, value)
      value

    # Sets a property according to the validation process
    setProperty = (name, value) ->
      prev = properties[name]
      throw new Error "Invalid assignment: property #{name} doesn't exist" if typeof prev is "undefined"
      throw new Error "Invalid assignment: property #{name} is a computed property and cannot be changed" if typeof prev is "function"
      throw new Error "Invalid assignment: forbidden to set a property (#{name}) to undefined"  if typeof value == "undefined"
      properties[name] = validate(name, prev, value)
      
    # Perform a deep copy of the given object
    copy = (obj) ->
      if typeof obj is "object"
        if Array.isArray obj
          return obj.slice 0
        else if typeof obj.clone is "function"
          return obj.clone()
        else
          nObj = {}
          for k, v of obj
            nObj[k] = copy v
          return nObj
      else return obj


    # ###################
    # Constructor logic #
    # ###################

    # Actually adds elements to the object
    for data in entityData
      if data.validators?
        for k, v of data.validators
          throw new Error "Validator for #{k} must be a function (got a #{typeof v})" if typeof v isnt "function"
          throw new Error "Computed property #{k} cannot have a validator" if typeof properties[k] is "function"
          validators[k] = v
      if data.reactions?
        for k, v of data.reactions
          throw new Error "Reaction #{k} is not a function (is #{v})" if typeof v isnt "function"
          reactions[k] = v
      if data.properties?
        for k, v of data.properties
          throw new Error "#{k} is a computed property but a validator has already been defined" if typeof v is "function" and validators[k]?
          properties[k] = v
          #setProperty k, v
    
    # #########################
    # Entity member functions #
    # #########################

    # Returns the property if it exists.
    # Copy any array/entity/other object to avoid modification from the outside
    @property = (property, args...) ->
      switch typeof p = properties[property]
        when "function"
          return p.apply(@protected, args)
        when "undefined"
          throw new Error "Invalid reference: property #{property} is not defined"
        when "object"
          return copy p
        else
          return p


    # Calls for a reaction to the event "message" from source "caller" with arguments "args"
    # Passes the caller and the argument list to the reaction callback and return the result of the function
    @react = (message, args...) ->
      f = reactions[message]
      throw new Error "Invalid reference: reaction #{message} is not defined" unless typeof f is "function"
      self = @protected
      self.setProperty = setProperty
      self.react = @react
      f.apply self, args

    # Checks whether an entity has a given property
    @hasProperty = (property) ->
      typeof properties[property] isnt "undefined"

    # Checks whether an entity has a given reaction
    @hasReaction = (reaction) ->
      typeof reactions[reaction] is "function"

    # Read-only version of the entity
    @protected =
      id: @id
      hasProperty: @hasProperty
      hasReaction: @hasReaction
      property: @property

    # Return an identical but independent copy of the calling entity
    @clone = ->
      new Entity properties: copy(properties), reactions: copy(reactions), validators: copy(validators)


  
  # CONSTRUCTOR #

# end class Entity

module.exports = Entity
