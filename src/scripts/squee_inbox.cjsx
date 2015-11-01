cx = require "classnames"
ChatMessage = require "./chat_message.jsx"


module.exports = React.createClass
	displayName: 'SqueeInbox'

	renderMessage: (msg) ->
		<ChatMessage
			renderEmotes={@props.emotesEnabled && Bem.doneLoading}
			msg={msg}
			key={msg.timestamp+msg.nick}/>

	render: ->
		<div className="squee-inbox">
			<i onClick={@props.onClear} title="Clear Squees" className="material-icons clear-all">clear_all</i>
			{@props.squees.map(@renderMessage)}
		</div>
