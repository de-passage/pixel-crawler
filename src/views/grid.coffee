Cell = require "./cell.coffee"

newClass = require "./newclass.coffee"

React = require "react"
{ div } = React.DOM

#Component holding the grid of "pixels"
Grid = newClass
  displayName: "Grid"
  render: ->
    grid = (
      for i in [0...@props.height]
        div
          className: "game-row"
          key: "row #{i}"
          for j in [0...@props.width]
            Cell
              controller: @props.tileController
              size: @props.pixelSize
              key: i * @props.width + j
              fog: false
              pos:
                x: j
                y: i
    )
    div {}, grid
# end class Grid

module.exports = Grid
