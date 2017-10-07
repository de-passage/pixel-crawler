# ############################
#           Logic            #
# ############################


# Handle the logic of the game. Distributes the actions and plays out the turns
class GameLogic
  constructor: (@map, @controller, @availableActions, @rules = {}) ->
    @turn = 0
    @actions = []
    @pause = false

  # Interrupts the game after the end of the current turn
  pause: -> @pause = true

  # Restart the game if paused
  restart: ->
    return unless @pause
    @pause = false
    @startTurn()


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
        play "move", x, y
      pass: resolve

    array = []

    @map.playableEntities.forEach (el) ->
      array.push new Promise (resolve) -> el.property "play", game(el, resolve)

    Promise.all array
    .then =>
      @playTurn(callback)

  # Process all the actions registered for the current turn
  # The 'callback' parameter is the function to run after the turn is complete
  playTurn: (callback) ->
    sortFun = @rules.initiative || (x) -> x # Grab the rule for initiative if exists or do nothing on sort()
    
    # Iterate over the registered actions
    for action in sortFun @actions
      a = @resolve(action)
      if a # If its an error, notify the controller
        @controller.emit "error", a, action
    @actions = []

    # Wrap up the turn
    @turn++
    callback?()


  # Checks whether an action can be resolved, 
  # if so return the appropriate callback
  resolve: (arg) ->
    { caller, action, args } = arg
    f = @availableActions[action]
    if f? and typeof f is "function"
      c = caller
      c.x = caller.x
      c.y = caller.y
      f.call(c, @map, args...)
    else
      Error "Action #{action} is not available"


module.exports = GameLogic
