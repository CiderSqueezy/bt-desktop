var TimeAgo = require("./timeago")
var cx = require("classnames")
var wutColors = require("./wutColors")
var React = require("react")
var _ = require("underscore")
var striptags = require("striptags")
let LinkEmbed = require("./link_embed.jsx")
let Utils = require("./utils.jsx")

let linkregex = /\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig

module.exports = class ChatMessage extends React.Component {
	shouldComponentUpdate(nextProps, nextState) {
		return 	nextProps.renderEmotes != this.props.renderEmotes ||
		nextProps.highlighted != this.props.highlighted ||
		nextProps.seoncdaryHighlighted != this.props.seoncdaryHighlighted ||
		nextProps.msg != this.props.msg
	}

	linkifyAndEmote(text, embedImages) {
		// For now just remove html.. This will ignore some chat markup
		let notags = striptags(text)
		if(text != notags) {
			console.log(text)
		}
		text = _.unescape(notags)
		// @TODO probably a more efficient way to do this all in one pass
		return Utils.mapAlternate(text.split(linkregex),
			(s) => Utils.componentizeString(s),
			(s,i) => <LinkEmbed key={`embed${i}`} url={s} embedImages={embedImages}/>
		)
	}

	render() {
		let msg = this.props.msg,
			body = msg.msg
		var embedImages = true

		switch(msg.emote) {
		case "request":
			body = `request ${body}`
			break
		case "drink":
			body = `drink ${body}`
			break
		case "spoiler":
			embedImages = false
			break
		case "poll":
			body = `has created a new poll: ${body}`
			break
		}

		let emotedMsg = this.linkifyAndEmote(body, embedImages),
			nickColor = msg.nick && wutColors.getUserColor(msg.nick),
			rowClass = {
				"msg-row": true,
				"squee": msg.isSquee,
				"self": msg.isSelf,
				"highlighted": this.props.highlighted,
				"seoncdaryHighlighted": this.props.seoncdaryHighlighted,
				"quote": body.indexOf("&gt;") === 0
			}

		if(msg.emote) {
			rowClass[msg.emote] = true
		}

		// For now treat inline spoilers as full message spoilers because of html stripping and FO4
		if(msg.emote == "spoiler" || body.indexOf("<span class=\"spoiler\">") != -1) {
			emotedMsg = <span className="spoiler">{emotedMsg}</span>
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
