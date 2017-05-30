require "./utility.coffee"
{ gameElements } = require "./models.coffee"
require "./logic.coffee"
require "./controllers.coffee"
{ TLView } =require "./views.coffee"

ReactDOM.render (TLView lookup: gameElements), document.getElementsByTagName("body")[0]
