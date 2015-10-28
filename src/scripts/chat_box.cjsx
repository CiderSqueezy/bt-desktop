Bem = require "./berrymotes"
ChatMessage = require "./chat_message"
_ = require "underscore"

module.exports = React.createClass
	displayName: 'ChatBox'

	getInitialState: ->
		selectedNick: false
		lastSeenIndex: 0

	componentDidMount: ->
		scroller = @refs.scroller.getDOMNode()
		scroller.scrollTop = scroller.scrollHeight

		if(window.ipc)
			window.ipc.on 'blur', @onBlur
			window.ipc.on 'focus', @onFocus

	componentDidUpdate: ->
		if @shouldScrollBottom
			scroller = @refs.scroller.getDOMNode()
			scroller.scrollTop = scroller.scrollHeight

	handleScroll: ->
		scroller = @refs.scroller.getDOMNode()
		@shouldScrollBottom = scroller.scrollTop + scroller.offsetHeight == scroller.scrollHeight
		return

	selectNick: (nick) ->
		@setState(selectedNick: if @state.selectedNick != nick then nick else false)

	onBlur: (e) ->
		# console.log "BLUR", @props.messages.length
		if @state.lastSeenIndex == 0 or @shouldScrollBottom
			@setState(lastSeenIndex: @props.messages.length)

	onFocus: (e) ->
		# console.log "focus", @props.messages.length
		if @state.lastSeenIndex == @props.messages.length
			@setState(lastSeenIndex: 0)

	render: ->
		renderEmoteIndex = @props.messages.length - 100
		chatRows = @props.messages.map (msg, i) =>
			<ChatMessage
				highlighted={msg.nick == @state.selectedNick}
				seoncdaryHighlighted={msg.msg.indexOf(@state.selectedNick) != -1}
				renderEmotes={@props.emotesEnabled && Bem.doneLoading && i > renderEmoteIndex}
				onSelectNick={@selectNick}
				msg={msg}
				key={msg.timestamp+msg.nick+i}/>

		if @state.lastSeenIndex && @state.lastSeenIndex != @props.messages.length
			taboutRow = <ChatMessage
				msg={emote: "tabout", msg: "#{@props.messages.length-@state.lastSeenIndex}"}
				key={"tabout"}/>
			chatRows.splice(@state.lastSeenIndex, 0, taboutRow)

		<div className="scroll-container">
			<div id="scroller" ref="scroller" className="scroller" onScroll={@handleScroll}>
				{chatRows}
			</div>
		</div>
