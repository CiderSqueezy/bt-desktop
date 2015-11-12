# Load css first thing. It gets injected in the <head> in a <style> element by
# the Webpack style-loader.
require '../styles/main.scss'

React = require 'react'
ReactDOM = require 'react-dom'
# Assign React to Window so the Chrome React Dev Tools will work.
window.React = React

# Router = require('react-router')
# Route = Router.Route

# Require route components.
App = require './app'

# routes = (
#   <Route handler={App}>
#   </Route>
# )
# Router.run(routes, (Handler) ->
ReactDOM.render <App/>, document.getElementById("app")
# )
