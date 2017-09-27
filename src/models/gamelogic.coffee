# ############################
#           Logic            #
# ############################


# Handle the logic of the game. Distributes the actions and plays out the turns
class GameLogic
  constructor: (@map, @controller) ->
    @turn = 0
    @actions = []

  # Process all the actions registered for the current turn
  playTurn: ->
    action() for action in @actions
    @actions = []
    @turn++
    @startTurn()


  # Hands out the handles to the controllable entities
  startTurn: ->

    @controller.emit "NewTurn"

    game = (x, y, entity, resolve) =>
      pos:
        x: x
        y: y
      map: @map.proxy()
      play: (action, args...) ->
        @actions.push caller: entity, action: action, args: args
        resolve()

    array = []

    @map.forEach (tile, x, y) ->
      for el in tile.entities
        array.push new Promise (resolve) -> el.react "play", game(x, y, el, resolve)

    Promise.all array
    .then =>
      @playTurn()

module.exports = GameLogic
