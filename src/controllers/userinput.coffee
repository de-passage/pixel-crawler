# User input model:
# The view links the controller to the DOM elements
# The controller holds the lookup tables for different
# states of the game
#
# When the user clicks something or presses a key, 
# execute the associated function and store the result if relevant.
# This will be the return value of the userInput function in the play()
# property of the player entity.

module.exports =
  class UserInputController
    constructor: (@state = {}) ->

    getInput: (callback) =>
      if @buffer
        callback @buffer
        @buffer = null
      else
        @callback = callback

    onEvent: (event) =>
      r = @state[event.key]?()
      if r
        if @callback
          @callback r
          @callback = null
        else
          @buffer = r
      



