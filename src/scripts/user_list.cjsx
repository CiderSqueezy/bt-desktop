wutColors = require "./wutcolors"

userSort = (a,b) ->
	if a.type == b.type
		a.nick.localeCompare(b.nick)
	else
		b.type - a.type

module.exports = React.createClass
	displayName: 'UserList'

	render: ->
		<div className="user-list">
			<ul>
				{@props.users.sort(userSort).map (user) ->
					<li key={user.nick} style={{color: wutColors.getUserColor(user.nick)}}>
						<span className={"type#{user.type}"}>
							{if user.type == 1
								"+"
							else if user.type == 2
								"@"
							}
						</span>
						<span>{user.nick}</span>
					</li>
				}
			</ul>
		</div>