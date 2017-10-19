message = require "./message.coffee"

module.exports =
  move: (direction) ->
    type: message.move
    direction: direction
  pass: ->
    type: message.pass
  spell: (name, x, y, id) ->
    type: message.spell
    name: name
    x: x
    y: y
    id: id
  attack: (x, y, id) ->
    type: message.attack
    x: x
    y: y
    id: id

