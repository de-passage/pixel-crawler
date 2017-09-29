# ############################
#           Logic            #
# ############################


# Handle the logic of the game. Distributes the actions and plays out the turns
class GameLogic
  constructor: (@map, @controller, @availableActions) ->
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
      play = (action, args...) ->
        @actions.push caller: entity, action: action, args: args, map: @map
        resolve()
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
    for action in @actions
      @resolve(action)
    @actions = []
    @turn++
    callback?()


  # Tries to resolve an action.
  # Returns true if the action was resolved, false otherwise
  resolve: (arg) ->
    { caller, action, args } = arg
    f = @availableActions[action]
    if f? and typeof f is "function"
      f.call(caller, map, args...)
      true
    else
      false


module.exports = GameLogic
