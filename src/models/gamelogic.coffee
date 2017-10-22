# ############################
#           Logic            #
# ############################


# Handle the logic of the game. Distributes the actions and plays out the turns
class GameLogic
  constructor: (@map, @controller, @rules = {}) ->
    @turn = 0

  playTurn: (callback) ->
    @controller.emit "new_turn", @turn

    playBuilder = (entity, resolve, reject) =>
      played = null
      play = (action, args...) =>
        if played
          return @controller.emit "error", new Error "An entity tried to act more than once (`#{action}` and `#{played}`)"
        else
          played = action
        @resolve caller: entity, action: action, args: args, map: @map
        @controller.emit action, caller: entity, map: @map, args: args
        resolve()
      pos: { x: entity.x, y: entity.y }
      map: @map.proxy()
      play: play
      move: (x, y) ->
        play "move", x, y, entity.x, entity.y
      pass: =>
        play "pass"

    filter = @rules.initiative || (x) -> x
    list = filter @map.playableEntities.slice()

    @nextAction list, callback, playBuilder

  nextAction: (list, callback, builder) ->
    if list.length > 0
      entity = list.shift()
      new Promise (resolve, reject) =>
        try
          @rules.play(entity, builder(entity, resolve, reject))
        catch e
          reject(e)
      .catch (e) =>
        try # Just ignore errors emitted by the controller in this case. The show must go on
          @controller.emit "error", e
      .then =>
        @nextAction list, callback, builder

    else
      @controller.emit "end_turn", @turn
      @turn++
      if typeof callback is "function"
        callback()
      else
        return Promise.resolve()

  # Checks whether an action can be resolved,
  # if so return the appropriate callback
  resolve: (arg) ->
    { caller, action, args } = arg
    f = @rules.actions[action]
    if f? and typeof f is "function"
      c = caller
      c.x = caller.x
      c.y = caller.y
      f.call(c, @map, args...)
    else
      throw Error "Action #{action} is not available"


module.exports = GameLogic
      

###
  # Hands out the game handle to the controllable entities and wait for
  # them to return an action to proceed with the game
  # The 'callback' parameter is the function to play after the turn is complete
  startTurn: (callback) ->
    return if @pause
    @controller.emit "NewTurn"

    game = (entity, resolve) =>
      play = (action, args...) =>
        @actions.push caller: entity, action: action, args: args, map: @map
        resolve()
      pos: { x: entity.x, y: entity.y }
      map: @map.proxy()
      play: play
      move: (x, y) ->
        play "move", x, y, entity.x, entity.y
      pass: resolve

    array = []

    entityFilter = @rules.entityFilter || (x) -> x

    entityFilter(@map.playableEntities).forEach (el) ->
      array.push new Promise (resolve) -> el.property "play", game(el, resolve)

    Promise.all array
    .then =>
      @playTurn(callback)

  # Process all the actions registered for the current turn
  # The 'callback' parameter is the function to run after the turn is complete
  playTurn: (callback) ->
    sortFun = @rules.initiative || (x) -> x # Grab the rule for initiative if exists or do nothing on sort()

    try
      # Iterate over the registered actions
      for action in sortFun @actions
        try
          @resolve(action)
          @controller.emit action.action, action
        catch e # If an error occurs, notify the controller
          @controller.emit "error", e, action

    finally # This is needed because the controller may throw during the catch, 
            # which would make the entire thing choke
      @actions = []

      # Wrap up the turn
      @turn++
      callback?()

###

