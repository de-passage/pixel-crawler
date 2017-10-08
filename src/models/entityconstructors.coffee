gameElements = require "./gameelements.coffee"
Entity = require "./entity.coffee"
Message = require "./message.coffee"
Tile = require "./tile.coffee"

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
      index = dir.indexOf input.direction
      # Build an adjusted position from the original position of the player and
      # the adjustment value in the lookup array
      nX= game.pos.x + adj[index][0]
      nY= game.pos.y + adj[index][1]

      # Request the position change
      game.move nX, nY

    when Message.attack
      game.play("attack", input.x, input.y, input.id)
    when Message.spell
      game.play("spell", input.x, input.y, input.name, input.id)
    when Message.pass
      game.pass()
    else
      throw Error("Invalid user input")


module.exports =
  Wall: ->
    new Tile new Entity(gameElements.wall)

  EmptySpace: ->
    new Tile new Entity(gameElements.emptySpace)


  # Execution model for player input:
  # GameLogic calls the `play` reaction with the custom `game` element 
  #     -> `play` calls the userInput with an interpretation callback and the map (proxy)
  #     -> `userInput` creates a Message and passes it to the callback
  #     -> the callback calls handleUserInput to transform the message in an appropriate call to the
  #        `play` function of `game`
  #     -> `play` (or one of its shorthands), resolve the underlying promise
  # Once this is done for every playable entity, execution of the turn resumes, actions are resolved and so on

  PlayableCharacter: (userInput, additionalProps...) ->
    playable =
      properties:
        play: (game) ->
          { @x, @y } = game.pos
          userInput.call(@, ((input) => handleUserInput(input, game)), game.map)
    new Entity(gameElements.character, playable, additionalProps...)

  Weapon: (props...) ->
    new Entity gameElements.item, gameElements.weapon, props...



