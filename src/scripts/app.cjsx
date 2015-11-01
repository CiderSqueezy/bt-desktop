TitleBar = require "./title_bar"
ChatBox = require "./chat_box.jsx"
ChatInput = require "./chat_input"
UserList = require "./user_list"
Playlist = require "./playlist"
LoginForm = require "./login_form"
PollsModal = require "./polls_modal"
SqueeInbox = require "./squee_inbox"

io = require 'socket.io-client'
_ = require 'underscore'

socket = io.connect('berrytube.tv:8344', {
	'connect timeout': 5000,
	'reconnect': true,
	'reconnection delay': 500,
	'reopen delay': 500,
	'max reconnection attempts': 10
})


squeeSound = new Audio("sounds/notify.wav")
drinkSound = new Audio("sounds/drink.wav")
ohMySound = new Audio("sounds/ohmy.wav")

if !window.appState
	window.appState =
		emotesEnabled: true
		viewer: false

		userlistOpen: false
		users: []

		playlistOpen: false
		playlist: []
		currentVideo: null

		pollListOpen: false
		polls: []

		squeeInboxOpen: false
		squees: []

		chatMessages: []
		drinkCount: 0

		sounds:
			squee: false
			drinks: false
			poll: false

# window.appState.chatMessages = require "./chatlog"

isSquee = (msg) -> appState.viewer && msg.toLowerCase().indexOf(appState.viewer.nick.toLowerCase()) != -1

module.exports = React.createClass
	displayName: 'App'

	getInitialState: -> appState

	componentDidMount: ->
		# User
		socket.on "newChatList", @newUserlist
		socket.on "userJoin", @userJoin
		socket.on "userPart", @userPart

		# Chat
		socket.on "chatMsg", @newMessage
		socket.on "drinkCount", @drinkCount

		# Playlist
		socket.on 'createPlayer', @updateCurrentVideo
		socket.on "hbVideoDetail", @updateCurrentVideo
		socket.on "forceVideoChange", @updateCurrentVideo
		socket.on "newPos", @updateCurrentVideo
		socket.on "recvPlaylist", @newPlaylist
		socket.on "recvNewPlaylist", @newPlaylist
		socket.on "addVideo", @addVideo
		socket.on "delVideo", @deleteVideo
		socket.on "addPlaylist", (data) => @addVideo(video) for video in data.videos

		# Poll
		socket.on "newPoll", @newPoll
		socket.on "clearPoll", @clearPoll
		socket.on "updatePoll", @updatePoll

		# Login
		socket.on "connect", @login
		socket.on "reconnecting", @reconnecting
		socket.on "reconnect", @login
		socket.on "loginError", @loginError
		socket.on "setNick", @setNick
		socket.on "kicked", @kicked

	# Playlist

	togglePlaylist: ->
		appState.playlistOpen = !appState.playlistOpen
		@setState(playlistOpen: appState.playlistOpen)

	updateCurrentVideo: (data) ->
		appState.currentVideo = data.video
		@setState(currentVideo: appState.currentVideo)

	newPlaylist: (data) ->
		console.log "newPlaylist", data
		isRefresh = !!appState.playlist.length
		appState.playlist = data
		@setState(playlist: appState.playlist)
		socket.emit("renewPos") if isRefresh

	addVideo: (data) ->
		console.log "addVideo", data

		videoIndex = (video) ->
			_.indexOf(appState.playlist, _.find(appState.playlist, (v) -> v.videoid is video.videoid))

		index = videoIndex(appState.currentVideo)

		if appState.currentVideo.videoid != data.sanityid || index == -1
			console.log "Sanity check failed, index: #{index}"
			socket.emit("refreshMyPlaylist")
			return

		if data.queue
			index++
			appState.playlist.splice(index,0,data.video)
		else
			index = appState.playlist.length
			appState.playlist.push(data.video)

		console.log "Adding video at #{index}"

		@setState(playlist: appState.playlist)

	deleteVideo: (data) ->
		console.log "deleteVideo", data
		if appState.currentVideo.videoid != data.sanityid
			socket.emit("refreshMyPlaylist")
			return

		appState.playlist.splice(data.position,1)
		@setState(playlist: appState.playlist)


	# Chat

	newMessage: (data) ->
		appState.chatMessages.push data.msg

		if !data.msg.ghost && data.msg.nick != appState.viewer?.nick and isSquee(data.msg.msg)
			data.msg.isSquee = true
			appState.squees.unshift data.msg
			@onSquee(data.msg)
		else if data.msg.nick == appState.viewer.nick
			data.msg.isSelf = true

		# if data.msg.emote is "drink"
			# drinkSound.play()

		# if appState.chatMessages.length > 1500
		# 	appState.chatMessages = appState.chatMessages.slice(appState.chatMessages.length-1000)

		@setState
			squees: appState.squees
			chatMessages: appState.chatMessages

	onSquee: (msg) ->
		nativeApp?.dock.setBadge("#{@state.squees.length}")
		nativeApp?.dock.bounce("critical")
		squeeSound.play()
		new Notification msg.nick,
			body: msg.msg

	toggleSqueeList: ->
		nativeApp?.dock.setBadge("")
		appState.squeeInboxOpen = !appState.squeeInboxOpen
		@setState(squeeInboxOpen: appState.squeeInboxOpen)

	toggleEmotes: ->
		appState.emotesEnabled = !appState.emotesEnabled
		@setState(emotesEnabled: appState.emotesEnabled)

	clearSquees: ->
		appState.squees = [];
		appState.squeeInboxOpen = false;
		@setState
			squees: appState.squees,
			squeeInboxOpen: appState.squeeInboxOpen

	sendMessage: (msg) ->
		socket.emit 'chat',
			msg: msg
			metadata:
				channel: 'main'
				flair: 0

	drunkCount: (drinks) ->
		appState.drinkCount = drinks
		@setState(drinkCount: appState.drinks)

	# Poll

	togglePollList: ->
		appState.pollListOpen = !appState.pollListOpen
		@setState(pollListOpen: appState.pollListOpen)

	newPoll: (data) ->
		console.log data
		data.index = appState.polls.length
		appState.polls[appState.polls.length-1].inactive = true if appState.polls.length
		appState.polls.push data
		ohMySound.play() if !data.ghost
		@setState(polls: appState.polls)

	clearPoll: (data) ->
		appState.polls[appState.polls.length-1].votes = data.votes || data
		appState.polls[appState.polls.length-1].inactive = true
		@setState(polls: appState.polls)

	updatePoll: (data) ->
		appState.polls[appState.polls.length-1].votes = data.votes
		@setState(polls: appState.polls)

	vote: (option) ->
		return if appState.polls[appState.polls.length-1].voted?
		appState.polls[appState.polls.length-1].voted = option
		socket.emit "votePoll", op: option
		@setState(polls: appState.polls)


	# Login

	reconnecting: ->
		console.log "Reconnecting..."
		@newMessage
			msg:
				emote: "system"
				msg: "Connection lost, attempting to reconnect..."
				timestamp: (new Date()).getTime()

	onLoginSubmit: (viewer) ->
		@setState(viewer: viewer, @login)

	loginError: (data) ->
		@setState
			viewer: false
			loginError: data.message

	login: ->
		return unless localStorage.getItem("nick") && localStorage.getItem("pass")
		socket.emit "setNick",
			nick: localStorage.getItem("nick") || ""
			pass: localStorage.getItem("pass") || ""
		socket.emit('myPlaylistIsInited')

	setNick: (data) ->
		appState.viewer =
			nick: data
			pass: localStorage.getItem("pass") || ""
		appState.loginError = false
		@setState
			viewer: appState.viewer
			loginError: appState.loginError

	kicked: (reason) ->
		msg = "You have been kicked"
		if reason
			msg += ": " + reason
		alert(msg)


	# User

	toggleUserList: ->
		appState.userlistOpen = !appState.userlistOpen
		@setState(userlistOpen: appState.userlistOpen)

	newUserlist: (data) ->
		appState.users = data
		@setState users: appState.users

	userJoin: (data) ->
		appState.users.push data
		@setState users: appState.users

	userPart: (data) ->
		index = _.indexOf appState.users, _.find appState.users, (u) -> u.nick is data.nick
		if index != -1
			appState.users.splice index, 1
			@setState users: appState.users


	render: ->
		<div id="main-container" className="container">
			<TitleBar
				polls={@state.polls}
				squees={@state.squees}
				currentVideo={@state.currentVideo}
				drinkCount={@state.drinkCount}
				emotesEnabled={@state.emotesEnabled}
				onClickSquees={@toggleSqueeList}
				onClickPollsBtn={@togglePollList}
				onClickUserBtn={@toggleUserList}
				onClickPlaylistBtn={@togglePlaylist}
				onClickEmotes={@toggleEmotes}/>
			<div className="chat">
				{if @state.userlistOpen
					<UserList users={@state.users} />}
				{if @state.playlistOpen
					<Playlist
						currentVideo={@state.currentVideo}
						playlist={@state.playlist} />}
				{if @state.pollListOpen
					<PollsModal
						polls={@state.polls}
						onVote={@vote}/>}
				{if @state.squeeInboxOpen
					<SqueeInbox
						squees={@state.squees}
						onClear={@clearSquees}
						/>}
				<ChatBox
					emotesEnabled={@state.emotesEnabled}
					messages={@state.chatMessages}/>
				{if @state.viewer && !@state.loginError
					<ChatInput
						users={@state.users}
						onSubmit={@sendMessage}/>
				else
					<LoginForm
						onSubmit={@onLoginSubmit}
						error={@state.loginError} />
				}
			</div>
		</div>
