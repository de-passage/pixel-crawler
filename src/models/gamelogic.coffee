# ############################
#           Logic            #
# ############################
# Handle the logic of the game. Distributes the actions and plays out the turns
class GameLogic

  # Process all the actions registered for the current turn
  playTurn: ->
    action() for action in @actions

  # Hands out the handles to the controllable entities
  startTurn: ->

  newMap: (generator) ->
    @map = generator(@player)

module.exports = GameLogic
