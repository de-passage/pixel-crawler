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
        obj.dispatchEvent(new CustomEvent(name))
        running = false
    obj.addEventListener(type, func)
throttle("resize", "optimizedResize")

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

module.exports =
  newClass: newClass
  docWidth: docWidth
  docHeight: docHeight
  normalizeEvent: normalizeEvent
