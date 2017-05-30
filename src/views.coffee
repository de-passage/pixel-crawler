{ div } = React.DOM
{ newClass, docHeight, docWidth, normalizeEvent } = require "./utility.coffee"
{ TileController } = require "./controllers.coffee"

# ############################
#       Views               #
# ############################
# Component holding a single "pixel"
Cell = newClass
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

# Component displaying the tooltip for the cells
Tooltip = newClass
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

#Component holding the grid of "pixels"
Grid = newClass
  render: ->
    grid = (
      for i in [0...@props.height]
        div
          className: "game-row"
          for j in [0...@props.width]
            Cell
              controller: @props.tileController
              size: @props.pixelSize
              key: i * @props.width + j
              fog: j < 25
              pos:
                x: j
                y: i
    )
    div {}, grid
# end class Grid

# Component holding the view on the game
# Handles the tooltip, ui, contains the grid
GameView = newClass
  pixelSize: (width, height) -> Math.floor Math.min(docHeight(), docWidth()) / Math.max(@width(), @height())
  width: -> @props.width
  height: -> @props. height
  displayWidth: -> @width() * @state.pixelSize
  displayHeight: -> @height() * @state.pixelSize
  startTimer: (x, y, event) ->
    @handleMouseMove x, y, event
    @timer = setTimeout ( => @setState showTooltip: true), 500
  clearTimer: ->
    @setState showTooltip: false
    clearInterval @timer
    @timer = null
  handleMouseMove: (x, y, event) ->
    event = normalizeEvent event
    @setState tooltip:
      pos: { x: event.pageX, y: event.pageY}
      tile: { x: x, y: y }
  tooltipContent: ->
    "#{JSON.stringify @state.tooltip}"
  getDefaultProps: -> width: 50, height: 50
  componentWillMount: ->
    @setState
      pixelSize: @pixelSize()
      tileController: new TileController @width(), @height(), @props.lookup,
        onMouseEnter: @startTimer
        onMouseMove: @handleMouseMove
        onMouseLeave: @clearTimer
    window.addEventListener "optimizedResize", (event) =>
      @setState pixelSize: @pixelSize()
  render: ->
    if(@state.showTooltip)
      tooltip = Tooltip
        x: @state.tooltip.pos.x
        y: @state.tooltip.pos.y
        key: "tooltip"
        @tooltipContent()
    # return
    div
      className: "game-grid"
      onMouseLeave: => @setState tooltip: null
      #onMouseMove: (event) => @handleMouseMove event
      style:
        marginTop: (docHeight() - @displayHeight()) / 2
        width: @displayWidth()
        height: @displayHeight()
      Grid
        tileController: @state.tileController
        height: @height()
        width: @width()
        pixelSize: @state.pixelSize
        key: "grid"
      tooltip
# end class GameView


# Top level component
# Handle the different menus
TLView = newClass
  render: ->
    GameView
      lookup: @props.lookup
# end class TLView

module.exports =
  TLView: TLView
