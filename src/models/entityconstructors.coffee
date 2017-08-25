gameElements = require "./gameelements.coffee"
Entity = require "./entity.coffee"
Message = require "./messages.coffee"

# Various constructors for basic entities

Wall = ->
  new Entity(gameElements.wall)

EmptySpace = ->
  new Entity(gameElements.emptySpace)


npc =
  properties:
    team: "enemies"

Player = (userInput) ->
  playable =
    reactions:
      play: (self, game) ->
        input = userInput()
        switch input.type
          when Message.move
            direction = input.direction

    properties:
      team: "player"

  new Entity(gameElements.character, playable)

Monster = ->
  new Entity(gameElements.character, npc)
