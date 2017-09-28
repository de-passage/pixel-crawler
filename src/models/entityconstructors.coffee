gameElements = require "./gameelements.coffee"
Entity = require "./entity.coffee"
Message = require "./message.coffee"

# ##################
# Utility functions #
# ##################

handleUserInput = (input, game) ->
  switch input.type
    when Message.move
      # Direction and position adjustment lookup. Extend the arrays to handle e.g. 8 directions
      dir = [  "up",  "left",  "down", "right"]
      adj = [[0, -1], [-1, 0], [0, 1], [1, 0]]
      # Match the direction with the lookup value
      index = dir.indexOf message.direction
      # Build an adjusted position from the original position of the player and
      # the adjustment value in the lookup array
      nX= game.pos.x + adj[index][0]
      nY= game.pos.y + adj[index][1]

      # Request the position change
      game.move nX, nY

    when Message.attack
      game.play("attack", x, y, id)
    when Message.spell
      game.done()
    else
      throw Error("Invalid user input")


module.exports =
  Wall: ->
    new Entity(gameElements.wall)

  EmptySpace: ->
    new Entity(gameElements.emptySpace)

  PlayerCharacter: (userInput, teamID, color) ->
    playable =
      reactions:
        play: (game) ->
          handleUserInput.call this, userInput(game), game
      properties:
        team: teamID
    new Entity(gameElements.character, playable)



