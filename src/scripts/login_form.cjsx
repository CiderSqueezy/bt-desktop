module.exports = React.createClass
	displayName: 'LoginForm'

	getInitialState: ->
		nick: localStorage.getItem("nick") || ""
		pass: localStorage.getItem("pass") || ""

	handleLogin: (e) ->
		e.preventDefault()
		return unless @state.nick?.length && @state.pass?.length

		localStorage.setItem("nick", @state.nick)
		localStorage.setItem("pass", @state.pass)

		@props.onSubmit
			nick: @state.nick
			pass: @state.pass

	handleChange: (e) ->
		if e.target == @refs.nick
			@setState(nick: e.target.value)
		else
			@setState(pass: e.target.value)

	render: ->
		<form className="form-inline login-box" onSubmit={@handleLogin}>
			<div className="pull-right">
				{if @props.error
					<span className="alert-danger">{@props.error}</span>}
				<div className="form-group">
					<label className="sr-only" htmlFor="userInput">Username</label>
					<input ref="nick" onChange={@handleChange} type="text" className="form-control" id="userInput" placeholder="Username" value={@state.nick} />
				</div>
				<div className="form-group">
					<label className="sr-only" htmlFor="passwordInput">Password</label>
					<input ref="pass" onChange={@handleChange} type="password" className="form-control" id="passwordInput" placeholder="Password" value={@state.pass} />
				</div>
				<button type="submit" className="btn btn-default">Sign in</button>
			</div>
		</form>
