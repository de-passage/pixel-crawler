gameElements = require "./gameelements.coffee"
Entity = require "./entity.coffee"
Message = require "./message.coffee"

# ##################
# Utility functions #
# ##################

handleUserInput = (input, self, game) ->
  switch input.type
    when Message.move
      # Direction and position adjustment lookup. Extend the arrays to handle e.g. 8 directions
      dir = [  "up",  "left",  "down", "right"]
      adj = [[0, -1], [-1, 0], [0, 1], [1, 0]]
      # Match the direction with the lookup value
      index = dir.indexOf message.direction
      # Build an adjusted position from the original position of the player and
      # the adjustment value in the lookup array
      newPosition =
        x: game.pos.x + adj[index][0]
        y: game.pos.y + adj[index][1]

      # Request the position change
      game.transfer self, newPosition
      game.done()

    when Message.attack
      game.done()
    when Message.spell
      game.done()
    else
      throw Error("Invalid user input")


module.exports =
  Wall: ->
    new Entity(gameElements.wall)

  EmptySpace: ->
    new Entity(gameElements.emptySpace)

  Character: (userInput, teamID) ->
    playable =
      reactions:
        play: (self, game) ->
          handleUserInput userInput(), self, game
      properties:
        team: teamID
    new Entity(gameElements.character, playable)



