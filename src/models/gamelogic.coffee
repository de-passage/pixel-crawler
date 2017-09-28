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

  # Process all the actions registered for the current turn
  playTurn: ->
    @resolve(action) for action in @actions
    @actions = []
    @turn++
    @startTurn()


  # Hands out the game handle to the controllable entities and wait for
  # them to return an action to proceed with the game
  startTurn: ->
    return if @pause
    @controller.emit "NewTurn"

    game = (entity, resolve) =>
      map: @map.proxy()
      play: (action, args...) ->
        @actions.push caller: entity, action: action, args: args
        resolve()

    array = []

    @map.playableEntities.forEach (el) ->
      array.push new Promise (resolve) -> el.react "play", game(el, resolve)

    Promise.all array
    .then =>
      @playTurn()


  # Tries to resolve an action.
  # Returns true if the action was resolved, false otherwise
  resolve: (arg) ->
    { caller, action, args } = arg
    f = @availableActions[action]
    if f? and typeof f is "function"
      f(caller, args...)
      true
    else
      false


module.exports = GameLogic
