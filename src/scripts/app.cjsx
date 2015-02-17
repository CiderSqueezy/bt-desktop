TitleBar = require "./title_bar"
ChatBox = require "./chat_box"
ChatInput = require "./chat_input"
UserList = require "./user_list"
Playlist = require "./playlist"
LoginForm = require "./login_form"
PollsModal = require "./polls_modal"

io = require 'socket.io-client'
_ = require 'underscore'

# window.mockChat = require "./chatlog"

socket = io.connect('berrytube.tv:8344')


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
		squees: []
		chatMessages: []
		polls: []
		drinkCount: 0


	# window.appState.chatMessages = mockChat

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
		socket.on "setNick", @setNick
		socket.on "kicked", @kicked
		socket.on "reconnecting", @reconnect

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
			squeeSound.play()
			appState.squees.unshift data.msg
		else if data.msg.nick == appState.viewer.nick
			data.msg.isSelf = true

		if data.msg.emote is "drink"
			drinkSound.play()

		# if appState.chatMessages.length > 1500
		# 	appState.chatMessages = appState.chatMessages.slice(appState.chatMessages.length-1000)

		@setState
			squees: appState.squees
			chatMessages: appState.chatMessages

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

	reconnect: ->
		@newMessage
			msg:
				msg: "Connection lost, attempting to reconnect..."

	setNick: (data) ->
		appState.viewer =
			nick: data
		@setState(viewer: appState.viewer)

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
				currentVideo={@state.currentVideo}
				drinkCount={@state.drinkCount}
				onClickUserBtn={@toggleUserList}
				onClickPlaylistBtn={@togglePlaylist}
				onClickPollsBtn={@togglePollList}/>
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
				<ChatBox
					emotesEnabled={@state.emotesEnabled}
					messages={@state.chatMessages}/>
				{if @state.viewer
					<ChatInput
						users={@state.users}
						onSubmit={@sendMessage}/>
				else
					<LoginForm socket={socket} />
				}
			</div>
		</div>
