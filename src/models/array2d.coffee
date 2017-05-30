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


