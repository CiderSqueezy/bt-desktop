cx = React.addons.classSet



module.exports = React.createClass
	displayName: 'TitleBar'

	getInitialState: ->
		menuOpen: false

	showBMSettings: ->

	toggleMenu: -> @setState(menuOpen: !@state.menuOpen)

	render: ->
		pollClass = 
			notify: @props.polls.length && !@props.polls[@props.polls.length-1].inactive && !@props.polls[@props.polls.length-1].voted?
			glyphicon: true
			"glyphicon-check": true

		squeeClass = 
			notify: @props.squees.length
			glyphicon: true
			"glyphicon-envelope": true

		<div id="title-bar" ng-controller="TitleBarCtrl">
			<img className="icon" src="favicon.png"/>
			<span className="title">
				BerryTube {if @props.currentVideo then <span className="now-playing">Now playing: {decodeURIComponent(@props.currentVideo.videotitle)} <span className={"drink-count #{"hidden" unless @props.drinkCount}"}>({@props.drinkCount} Drinks)</span> </span>}
			</span>
			<div className="menu">
				{if @props.squees.length then <span className={cx(squeeClass)} title="squees" onClick={@props.onClickSquees}></span>}
				<span className={cx(pollClass)} title="Poll" onClick={@props.onClickPollsBtn}></span>
				<span className="glyphicon glyphicon-user" title="Toggle user list" onClick={@props.onClickUserBtn}></span>
				<span className="glyphicon glyphicon-list" title="Toggle playlist" onClick={@props.onClickPlaylistBtn}></span>
				<span>
					<span className={"dropdown #{"open" if @state.menuOpen}"}>
						<a className="dropdown-toggle" onClick={@toggleMenu}>
							<span className="glyphicon glyphicon-cog"></span>
						</a>
						<ul className="dropdown-menu dropdown-menu-right">
							<li><a onClick={@props.onClickEmotes}><i className="glyphicon glyphicon-heart-empty"></i> {if @props.emotesEnabled then "Disable" else "Enable"} Emotes</a></li>
							<li><a onClick={Bem.dataRefresh}><i className="glyphicon glyphicon-refresh"></i> Refresh Emotes</a></li>
							{if window.nativeApp then <li className="divider"></li>}
							{if window.nativeApp then <li><a onClick={@showDevTools}><i className="glyphicon glyphicon-wrench"></i> Show Devtools</a></li>}
							<li className="divider"></li>
							<li ng-show="User" ><a ng-click="logout()"><i className="glyphicon glyphicon-log-out"></i> Logout</a></li>
						</ul>
					</span>
				</span>
			</div>
		</div>
