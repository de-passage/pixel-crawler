
module.exports =
  class UserInputController
    constructor: ->
      @waitingForInput = false


    awaitMessage: ->
      @waitingForInput = true

    onkeyPress: ->
      console.log "Here"



