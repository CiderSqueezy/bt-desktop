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

		<div id="title-bar" ng-controller="TitleBarCtrl">
			<img className="icon" src="favicon.png"/>
			<span className="title">
				BerryTube {if @props.currentVideo then <span className="now-playing">Now playing: {decodeURIComponent(@props.currentVideo.videotitle)} <span className={"drink-count #{"hidden" unless @props.drinkCount}"}>({@props.drinkCount} Drinks)</span> </span>}
			</span>
			<div className="menu">
				<span className="glyphicon glyphicon-envelope" ng-className="{'notify':squees.length}" title="squees" ng-click="showSquees()"></span>
				<span className={cx(pollClass)} title="Poll" onClick={@props.onClickPollsBtn}></span>
				<span className="glyphicon glyphicon-user" title="Toggle user list" onClick={@props.onClickUserBtn}></span>
				<span className="glyphicon glyphicon-list" title="Toggle playlist" onClick={@props.onClickPlaylistBtn}></span>
				<span>
					<span className={"dropdown #{"open" if @state.menuOpen}"}>
						<a className="dropdown-toggle" onClick={@toggleMenu}>
							<span className="glyphicon glyphicon-cog"></span>
						</a>
						<ul className="dropdown-menu dropdown-menu-right">
							<li ><a onClick={@showBMSettings}><i className="glyphicon glyphicon-heart-empty"></i> Emote Settings</a></li>
							<li ><a ng-click="refreshEmotes()"><i className="glyphicon glyphicon-refresh"></i> Refresh Emotes</a></li>
							<li ng-show="inNativeApp" className="divider"></li>
							<li ng-show="inNativeApp"><a ng-click="showDevTools()"><i className="glyphicon glyphicon-wrench"></i> Show Devtools</a></li>
							<li ng-show="User" className="divider"></li>
							<li ng-show="User" ><a ng-click="logout()"><i className="glyphicon glyphicon-log-out"></i> Logout</a></li>
						</ul>
					</span>
				</span>
			</div>
		</div>
