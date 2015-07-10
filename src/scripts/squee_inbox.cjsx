$ = require "jquery"
cx = React.addons.classSet
ChatMessage = require "./chat_message"


module.exports = React.createClass
	displayName: 'SqueeInbox'

	renderMessage: (msg) ->
		<ChatMessage
			renderEmotes={@props.emotesEnabled && Bem.doneLoading}
			msg={msg}
			key={msg.timestamp+msg.nick}/>

	render: ->
		<div className="squee-inbox">
			<div onClick={@props.onClear} title="Clear Squees" className="clear-all glyphicon glyphicon-trash"></div>
			{@props.squees.map(@renderMessage)}
		</div>
