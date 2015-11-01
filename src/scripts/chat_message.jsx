var TimeAgo = require("./timeago")
var cx = require("classnames")
var wutColors = require("./wutColors")
var ReactDOM = require("react-dom")
var React = require("react")

module.exports = class ChatMessage extends React.Component {
	componentDidMount() {
		if(Bem.doneLoading){
			Bem.postEmoteEffects($(ReactDOM.findDOMNode(this)))
		}
	}

	componentDidUpdate() {
		if(Bem.doneLoading){
			Bem.postEmoteEffects($(ReactDOM.findDOMNode(this)))
		}
	}

	shouldComponentUpdate(nextProps, nextState) {
		return 	nextProps.renderEmotes != this.props.renderEmotes ||
		nextProps.highlighted != this.props.highlighted ||
		nextProps.seoncdaryHighlighted != this.props.seoncdaryHighlighted ||
		nextProps.msg != this.props.msg
	}

	linkify(text) {
		var split = text.split(/\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig)
		var result = []
		for(var i = 0; i < split.length; ++i) {
			var s = split[i]
			if(!s || s == "" || s == " ") { continue }
			if(i + 1 < split.length && split[i + 1] == undefined && !(i > 0 && split[i-1] && split[i-1].match(/<a href="\/\/$/))) {
				if(s.match(/\.(jpg|jpeg|png|gif|bmp|webm)$/gi)) {
					result.push(<a key={`thumb${i}`} className='thumbnail' href={s} target='_blank'><img src={s.replace(".webm",".gif")}/></a>)
				} else {
					result.push(<a key={`link${i}`} href={s} target='_blank'>{s}</a>)
				}
			} else {
				if(this.props.renderEmotes) {
					s = Bem.applyEmotesToStr(s)
				}
				result.push(<span key={`text#{i}`} dangerouslySetInnerHTML={{__html: s}}/>)
			}
		}

		return result
	}

	render() {
		let msg = this.props.msg,
			body = msg.msg

		switch(msg.emote) {
		case "request":
			body = `request ${body}`
			break
		case "drink":
			body = `drink ${body}`
			break
		case "poll":
			body = `has created a new poll: ${body}`
			break
		}

		let emotedMsg = this.linkify(body),
			nickColor = msg.nick && wutColors.getUserColor(msg.nick),
			rowClass = {
				"msg-row": true,
				"squee": msg.isSquee,
				"self": msg.isSelf,
				"highlighted": this.props.highlighted,
				"seoncdaryHighlighted": this.props.seoncdaryHighlighted,
				"quote": msg.msg.indexOf("&gt;") === 0
			}

		if(msg.emote) {
			rowClass[msg.emote] = true
		}

		return (
			<div className={cx(rowClass)}>
				{msg.nick ? <span className="user" title={`click to highlight all messages by ${msg.nick}`} onClick={this.props.onSelectNick && this.props.onSelectNick.bind(this, msg.nick)} style={{color: nickColor}}>{msg.nick}&nbsp;</span> : null}
				{emotedMsg}
				{msg.timestamp ? <TimeAgo className="timestamp" date={(new Date(msg.timestamp)).getTime()} /> : null }
			</div>
		)
	}
}
