require("../styles/main.scss")

window.socket = window.socket || {on(){}}
var React = require("react/addons")
window.React = React

var ChatBox = require("./chat_box.jsx")
var ChatInput = require("./chat_input")

var SqueezyChat = React.createClass({
	displayName: "SqueezyChat",

	getInitialState() {
		return { messages: [], users: [] }
	},

	componentDidMount() {
		window.socket.on("chatMsg", this.newMessage)
	},

	newMessage(data) {
		this.state.messages.push(data.msg)
		this.setState({
			messages: this.state.messages
		})
	},

	render() {
		return <div className="chat">
			<ChatBox
				emotesEnabled={true}
				messages={this.state.messages}/>
			<ChatInput
				users={this.state.users}
				onSubmit={this.sendMessage}/>
		</div>
	}
})

var chatpane = document.getElementById("chatpane") || document.body
React.render(<SqueezyChat/>, chatpane)
