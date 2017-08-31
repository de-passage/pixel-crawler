module.exports =
  # Utility class holding a 2d array
  class Array2D
    constructor: (width, height) ->
      throw new Error "Array2D constructor expect two non-zero integers" unless height and width
      array = new Array(width * height)

      validate = (x, y) ->
        throw new Error "Tried to access (#{x}, #{y}) in an Array2D of dimensions (#{width}, #{height})" if x < 0 or y < 0 or x >= width or y >= height

      # Returns the value at (x, y)
      @at = (x, y) ->
        validate x, y
        array[ x + y * width ]

      # Sets the value at (x, y) to v
      @set = (x, y, v) ->
        validate x, y
        array[ x + y * width ] = v

      # Iterate over the entire array (height first) and
      # apply the value at every step to the callback function
      # along with its coordinates
      @forEach = (callback) ->
        for x in [0...width]
          for y in [0...height]
            callback array[ x + y * width ], x, y

      @width = width
      @height = height

  # end class Array2D
