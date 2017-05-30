ReactDOM = require "react-dom"
View = require "./views/tlview.coffee"
TileController = require "./controllers/tilecontroller.coffee"


$ -> ReactDOM.render (View tileController: new TileController), $("#react-content")[0]
