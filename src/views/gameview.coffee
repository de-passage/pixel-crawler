Tooltip = require "./tooltip.coffee"
Grid = require "./grid.coffee"

{ docHeight, docWidth, normalizeEvent } = require "./utility.coffee"

React = require "react"
{ div } = React.DOM

newClass = require "./newclass.coffee"

# Component holding the view on the game
# Handles the tooltip, ui, contains the grid
GameView = newClass

  displayName: "GameView"

  # Short-hand to calculate the size of an individual cell, or "pixel" on the screen
  pixelSize: (width, height) ->
    Math.floor Math.min(docHeight(), docWidth()) / Math.max(@width(), @height())

  # The width of the grid, in number of cells
  # Defined here because we need to know it for proper display inside the context
  width: -> @props.width

  # The height of the grid, in number of cells
  height: -> @props. height

  # The width of the grid in pixels
  displayWidth: -> @width() * @state.pixelSize

  # The height of the grid in pixels
  displayHeight: -> @height() * @state.pixelSize

  # Set the timeout to show the tooltip
  startTimer: (x, y, event) ->
    @handleMouseMove x, y, event
    @timer = setTimeout ( => @setState showTooltip: true), 500

  # Clears the timeout and hide the tooltip
  clearTimer: ->
    @setState showTooltip: false
    clearInterval @timer
    @timer = null

  # When the mouse moves inside a cell, move the tooltip with the cursor
  handleMouseMove: (x, y, event) ->
    event = normalizeEvent event
    @setState tooltip:
      pos: { x: event.pageX, y: event.pageY}
      tile: { x: x, y: y }

  # Returns the formated content to be displayed in the tooltip
  tooltipContent: ->
    "#{JSON.stringify @state.tooltip}"

  getDefaultProps: -> width: 100, height: 100

  componentWillMount: ->
    @props.tileController.onMouseEnter = @startTimer
    @props.tileController.onMouseMove = @handleMouseMove
    @props.tileController.onMouseLeave = @clearTimer
    @setState pixelSize: @pixelSize()
    window.addEventListener "optimizedResize", (event) =>
      @setState pixelSize: @pixelSize()

  render: ->
    if(@state.showTooltip)
      tooltip = Tooltip
        x: @state.tooltip.pos.x
        y: @state.tooltip.pos.y
        key: "tooltip"
        @tooltipContent()
    div
      className: "game-grid"
      onMouseLeave: => @setState tooltip: null
      onKeyPress: @props.inputController.onEvent
      style:
        marginTop: (docHeight() - @displayHeight()) / 2
        width: @displayWidth()
        height: @displayHeight()
      Grid
        tileController: @props.tileController
        height: @height()
        width: @width()
        pixelSize: @state.pixelSize
        key: "grid"
      tooltip
#
# end class GameView

module.exports = GameView
