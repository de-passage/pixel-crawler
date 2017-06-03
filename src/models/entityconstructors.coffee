gameElements = require "./gameelements.coffee"
Entity = require "./entity.coffee"

# Various constructors for basic entities

Wall = ->
  new Entity(gameElements.wall)
