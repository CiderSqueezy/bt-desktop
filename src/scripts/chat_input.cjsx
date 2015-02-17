_ = require("underscore")
EmoteSearch = require "./emote_search"

escapeForRegex = (word) ->
	word.replace('[', '\\[').replace('(','\\(').replace('/', '\\/')

module.exports = React.createClass
	displayName: 'ChatInput'

	getInitialState: ->
		message: ""
		searchEmoteString: false

	handleSubmit: (e) ->
		e.preventDefault()
		@props.onSubmit?(@state.message)
		@tabbed = false
		@setState
			message: ""
			searchEmoteString: false

	handleKeyUp: (e) ->
		keyCode = e.keyCode or e.which

		if keyCode == 13 # enter
			@handleSubmit(e)
			return

		sentence = @state.message
		if !sentence
			@tabbed = false
			return

		word = sentence.split(/[\s]/).pop().toLowerCase()

		if @tabbed and word.length
			if word[0] == "/"
				@setState(searchEmoteString: word.replace(/^\//g,""))

			match = _.find @props.users, (u) -> u.nick.toLowerCase().match(word)
			if match
				search = new RegExp(word + "$", "gi")
				@setState(message: sentence.replace(search, "#{match.nick}: "))

		if @state.searchEmoteString && keyCode is 27 # Esc
			search = new RegExp(escapeForRegex(word) + "$", "gi")
			@setState
				message: sentence.replace(search, "")
				searchEmoteString: false

		@tabbed = false


		return

	handleKeyDown: (e) ->
		keyCode = e.keyCode or e.which
		if keyCode is 9 # Tab
			e.preventDefault()
			@tabbed = true

		return

	onChange: (e) ->
		@setState(message: e.target.value)

	handleEmoteSelected: (emoteId) ->
		search = new RegExp("/" + @state.searchEmoteString + "$", "gi");
		@setState
			message: @state.message.replace(search, "[](/" + Bem.emotes[emoteId].names[0] + ") ");
			searchEmoteString: false

		@refs.input.getDOMNode().focus()


	render: ->
		<div className="input-box">
			{if @state.searchEmoteString
				<EmoteSearch
					emoteSelected={@handleEmoteSelected}
					search={@state.searchEmoteString}/>}
			<input
				id="chat-input"
				type="text"
				ref="input"
				autoComplete="off"
				placeholder="Message"
				value={@state.message}
				onChange={@onChange}
				onKeyUp={@handleKeyUp}
				onKeyDown={@handleKeyDown}
				microcomplete="chatInput"
				source="users() | userNick" />
		</div>
