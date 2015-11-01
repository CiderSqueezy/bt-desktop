cx = require "classnames"

module.exports = React.createClass
	displayName: 'TitleBar'

	getInitialState: ->
		menuOpen: false

	showBMSettings: ->

	toggleMenu: -> @setState(menuOpen: !@state.menuOpen)

	render: ->
		pollClass =
			"notify": @props.polls.length && !@props.polls[@props.polls.length-1].inactive && !@props.polls[@props.polls.length-1].voted?

		squeeClass =
			"notify": @props.squees.length

		dropdown =
			<ul className="dropdown-menu">
				<li><a onClick={@props.onClickEmotes}><i className="material-icons">favorite</i> {if @props.emotesEnabled then "Disable" else "Enable"} Emotes</a></li>
				<li><a onClick={Bem.dataRefresh}><i className="material-icons">refresh</i> Refresh Emotes</a></li>
				{if window.nativeApp then <li className="divider"></li>}
				{if window.nativeApp then <li><a onClick={@showDevTools}><i className="material-icons">build</i> Show Devtools</a></li>}
				<li className="divider"></li>
				<li ng-show="User" ><a ng-click="logout()"><i className="material-icons">exit_to_app</i> Logout</a></li>
			</ul>

		<div id="title-bar" ng-controller="TitleBarCtrl">
			<img className="icon" src="favicon.png"/>
			<span className="title">
				BerryTube {if @props.currentVideo then <span className="now-playing">Now playing: {decodeURIComponent(@props.currentVideo.videotitle)} <span className={"drink-count #{"hidden" unless @props.drinkCount}"}>({@props.drinkCount} Drinks)</span> </span>}
			</span>
			<div className="menu">
				<span className={cx(squeeClass)} title="Toggle Squees" onClick={@props.onClickSquees}>
					<i className="material-icons">mail</i>
				</span>
				<span className={cx(pollClass)} title="Toggle Polls" onClick={@props.onClickPollsBtn}>
					<i className="material-icons">check_box</i>
				</span>
				<span title="Toggle user list" onClick={@props.onClickUserBtn}>
					<i className="material-icons">people</i>
				</span>
				<span title="Toggle playlist" onClick={@props.onClickPlaylistBtn}>
					<i className="material-icons">video_library</i>
				</span>
				<span className="mdl-button mdl-button--icon" onClick={@toggleMenu}>
					<i className="material-icons">more_vert</i>
					{if @state.menuOpen then dropdown}
				</span>
			</div>
		</div>
