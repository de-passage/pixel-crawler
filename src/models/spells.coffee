Entity = require "./entity.coffee"
{ spell } = require "./gameelements.coffee"

spells =
  heal:
    reactions:
      effect: (caster) -> caster.react("heal", 5)

list = {}

for name, props of spells
  list[name] = new Entity spell, props

module.exports = list
