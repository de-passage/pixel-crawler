React = require "react"
{ div } = React.DOM

newClass = require "./newclass.coffee"

# Component displaying the tooltip for the cells
Tooltip = newClass
  displayName: "Tooltip"
  render: ->
    div
      className: "tooltip"
      key: "tooltip"
      ref: (el) =>
        # Positions the tooltip correctly
        if el?
          x = @props.x + 15
          y = @props.y
          rect = el.parentElement.getBoundingClientRect()
          if x > rect.right - el.clientWidth
            x = @props.x - el.clientWidth - 5
          if y > rect.bottom - el.clientHeight
            y = @props.y - el.clientHeight
          el.style.left = "#{x}px"
          el.style.top =  "#{y}px"
      style: maxWidth: 150
      @props.children
# end class Tooltip

module.exports = Tooltip
