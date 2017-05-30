GameView = require "./gameview.coffee"
newClass = require "./newclass.coffee"

# Top level component
# Handle the different menus
View = newClass
  displayName: "Top level view"
  render: ->
    GameView
      tileController: @props.tileController

# end class TLView

module.exports = View
