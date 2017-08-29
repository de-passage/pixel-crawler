newClass = require "./newclass.coffee"

{ div } = require("react").DOM

# Component holding a single "pixel"
Cell = newClass

  displayName: "Cell"

  getInitialState: ->
    color: ["blue", "red", "green", "purple", "cyan", "orange", "yellow", "yellowgreen"][Math.floor Math.random() * 8]

  componentWillMount: ->
    @props.controller.registerTile @props.pos.x, @props.pos.y, (color) =>
      @setState color: color

  render: ->
    div
      className: "game-cell"
      onMouseMove: (event) =>
        @props.controller.onMouseMove @props.pos.x, @props.pos.y, event
      onMouseEnter: (event) =>
        @props.controller.onMouseEnter @props.pos.x, @props.pos.y, event
      onMouseLeave: =>
        @props.controller.onMouseLeave()
      style:
        width: @props.size
        height: @props.size
        backgroundColor: @state.color
      if @props.fog then div { className: "fog-of-war" }
# end class Cell

module.exports = Cell
