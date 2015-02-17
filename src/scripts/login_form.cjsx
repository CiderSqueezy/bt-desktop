module.exports = React.createClass
	displayName: 'LoginForm'

	getInitialState: ->
		error: false
		nick: localStorage.getItem("nick") || ""
		pass: localStorage.getItem("pass") || ""

	componentDidMount: ->
		@props.socket.on "loginError", @handleLoginError
		@login() if @state.nick?.length && @state.pass?.length

	componentDidUnmount: ->
		console.log "UN"
		@props.socket.off "loginError", @handleLoginError

	handleLoginError: (data) ->
		@setState
			error: data.message

	login: ->
		console.log "Log in with", @state.nick, @state.pass
		@props.socket.emit "setNick",
			nick: @state.nick
			pass: @state.pass

	handleLogin: (e) ->
		e.preventDefault()
		if @state.nick?.length && @state.pass?.length
			localStorage.setItem("nick", @state.nick)
			localStorage.setItem("pass", @state.pass)
			@login()

	handleChange: (e) ->
		if e.target == @refs.nick.getDOMNode()
			@setState(nick: e.target.value)
		else
			@setState(pass: e.target.value)

	render: ->
		<form className="form-inline login-box" onSubmit={@handleLogin}>
			<div className="pull-right">
				{if @state.error
					<span className="alert-danger">{@state.error}</span>}
				<div className="form-group">
					<label className="sr-only" for="userInput">Username</label>
					<input ref="nick" onChange={@handleChange} type="text" className="form-control" id="userInput" placeholder="Username" value={@state.nick} />
				</div>
				<div className="form-group">
					<label className="sr-only" for="passwordInput">Password</label>
					<input ref="pass" onChange={@handleChange} type="password" className="form-control" id="passwordInput" placeholder="Password" value={@state.pass} />
				</div>
				<button type="submit" className="btn btn-default">Sign in</button>
			</div>
		</form>
