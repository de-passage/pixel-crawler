React = require "react"

# Helper functions
# React class creation
newClass = (specs) -> React.createFactory React.createClass specs

module.exports =  newClass
