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
    #@startTurn()


  # Hands out the handles to the controllable entities
  startTurn: ->
    @controller.emit "NewTurn"
    game = (x, y, resolve) =>
      pos:
        x: x
        y: y
      map: @map
      play: (action) ->
        @actions.push action
      transfer: (source, dest) ->
        tile = @map.at(source.x, source.y)
        en = tile.removeEntity (v) -> v.id == source.id
        @map.at(dest.x, dest.y).addEntity(en)

      done: resolve

    array = []

    @map.forEach (tile, x, y) ->
      for el in tile.entities
        array.push new Promise (resolve) -> resolve() #el.react "play", game(x, y, resolve)

    Promise.all array
    .then =>
      @playTurn()

module.exports = GameLogic
