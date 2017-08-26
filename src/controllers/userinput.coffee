
module.exports =
  class UserInputController
    constructor: ->
      @waitingForInput = false


    awaitMessage: ->
      @waitingForInput = true
    

