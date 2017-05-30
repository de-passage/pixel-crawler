{ div } = React.DOM
# Helper functions
# React class creation
newClass = (specs) -> React.createFactory React.createClass specs

# From MDN, optimize the resizing event which would otherwise fire too often
throttle = (type, name, obj) -> 
    obj = obj || window
    running = false
    func = ->
      return if (running)
      running = true
      requestAnimationFrame ->
        obj.dispatchEvent(new CustomEvent(name));
        running = false;
    obj.addEventListener(type, func);
throttle("resize", "optimizedResize");
      
# Makes sure that an event has the right properties 
normalizeEvent = (event) ->
  event = event || window.event
  if (event.pageX == null && event.clientX != null) 
    eventDoc = (event.target && event.target.ownerDocument) || document
    doc = eventDoc.documentElement
    body = eventDoc.body
    event.pageX = event.clientX +
    (doc && doc.scrollLeft || body && body.scrollLeft || 0) -
    (doc && doc.clientLeft || body && body.clientLeft || 0)
    event.pageY = event.clientY +
    (doc && doc.scrollTop  || body && body.scrollTop  || 0) -
    (doc && doc.clientTop  || body && body.clientTop  || 0 )
  return event

#Returns the width of the document
docWidth = ->
  window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth || 0
  
#Returns the height of the document
docHeight = ->
  window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 0
# End of helper functions

# ############################
#       Models               #
# ############################

# Stuffs that can be displayed on screen with their basic behaviour regarding character vision
# seethrough: Indicates whether or not the element blocks vision
# fog: Indicates whether or not the element is visible throught the fog of war  
# color: color of the tile on screen
gameElements =
  wall: 
    seethrough: false
    color: "grey"
    fog: true
  character:
    seethrough: true
    color: "red"
    fog: false
  item: 
    seethrough: false
    fog: true
    color: "yellow"
# end gameElement      
        
# General entity class
# Defines general properties of game entities
class Entity
  reactions = {}
  # Create an entity from the pieces of data passed to it
  constructor: (entityData...) ->
    for data in entityData
      reactions[k] = v for k, v in data when k not in ["turn"]
   
  # Calls for a reaction to the event "messaage" from source "caller" with arguments "args"
  # If the reaction is a function, passes the caller and args as arguments and call the callback
  # with the result of the function. 
  # If the reaction is a value, then calls the callback with the value.
  # Returns false and do nothing if the reaction is undefined, returns true otherwise
  react: (message, caller, args, callback) ->
    f = reactions[message]
    return false unless f?
    callback = args if typeof args == "function" and !callback? 
    if typeof f == "function"
      callback f.apply null, [caller, args...]
    else
      callback f
    return true
   
# end class Entity

# Defines the content of a single tile on the game map
class Tile
  constructor: (ter, es...) ->
    terrain = ter
    entities = es
  terrain: (t) ->
    if t? then terrain = t else terrain
  addEntity: (en) ->
    entities.push en
  removeEntity: (callback) ->
    i = idx for val, idx in entities when callback(val)
    entities.splice i, 1 if i?
# end class Tile

# Utility class holding a 2d array  
class Array2D
  constructor: (@width, @height) ->
    array = new Array(@width * @height)
  at: (x, y) ->
    array[ x + y * @width ]
  set: (x, y, v) ->
    array[ x + y * @width ] = v
  forEach: (callback) ->
    for x in [0...@width]
      for y in [0...@height]
        callback array[ x + y * @width ], x, y
# end class Array2D


# ############################
#           Logic            #
# ############################
# Handle the logic of the game. Distributes the actions and plays out the turns 
class GameLogic
  # Process all the actions registered for the current turn
  playTurn: ->
    action() for action in @actions
  # Hands out the handles to the controllable entities
  startTurn: ->
    @map.forEach (tile, x, y) =>
      entity?.turn(x, y, @map, ((a) => @actions.push a), )
    
  newMap: (generator) ->
    { map, startingPosition, entities } = generator()

#temporary stuff
map = new Array2D 100, 100

# ############################
#       Controllers          #
# ############################
# Controller for individual display cells.
# Dispatch tile changing information to the correct cells
class TileController
  constructor: (@width, @height, @lookup, @tooltipManager) ->
    @tiles = new Array(@width * @height)
  registerTile: (x, y, f) ->
    @tiles[x + y * @width] = f
  updateTile: (x, y, data) ->
    @tiles[x + y * @width](@lookup data)
  onMouseEnter: (x, y, event) ->
    @tooltipManager.onMouseEnter(x, y, event)
  onMouseMove: (x, y, event) ->
    @tooltipManager.onMouseMove(x, y, event)
  onMouseLeave: (x, y) ->
    @tooltipManager.onMouseLeave()
# end class TileController

# Controller for the game itself
# Handles general event dispatching and calling the game engine
# when needed to run the game
class GameController
  contructor: (@map) ->
    @events = {}
  on: (event, action) ->
    @events[event] ?= []
    @events[event].push action
  emit: (event, args...) ->
    obs(args...) for obs in @events[event]
  render: ->
    @emit "render", @map
    
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
      tooltip
# end class GameView


# Top level component
# Handle the different menus
TLView = newClass
  render: ->
    GameView
      lookup: @props.lookup
# end class TLView

ReactDOM.render (TLView lookup: gameElements), document.getElementsByTagName("body")[0]
