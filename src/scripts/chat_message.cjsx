Bem = require "./berrymotes"
TimeAgo = require "./timeago"
$ = require "jquery"
cx = React.addons.classSet
wutColors = require "./wutColors"


module.exports = React.createClass
	displayName: 'ChatMessage'

	componentDidMount: ->
		return unless Bem.doneLoading
		Bem.postEmoteEffects($(@getDOMNode()))
	# 	Bem.walk @getDOMNode()

	componentDidUpdate: ->
		return unless Bem.doneLoading
		Bem.postEmoteEffects($(@getDOMNode()))
	# 	Bem.walk @getDOMNode()
	

	shouldComponentUpdate: (nextProps, nextState) ->
		nextProps.renderEmotes != @props.renderEmotes || nextProps.highlighted != @props.highlighted || nextProps.seoncdaryHighlighted != @props.seoncdaryHighlighted || nextProps.msg != @props.msg

	linkify: (text) ->
		split = text.split(/\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/ig)
		result = []
		for s,i in split when s?
			if i + 1 < split.length && split[i + 1] == undefined && !(i > 0 && split[i-1] && split[i-1].match(/<a href="\/\/$/))
				if s.match(/\.(jpg|jpeg|png|gif|bmp)$/gi)
					result.push("<a class='thumbnail' href='#{s}' target='_blank'><img src='#{s}'/></a>")
				else
					result.push("<a href='#{s}' target='_blank'>#{s}</a>")
			else
				result.push(s)

		return result.join("");


	render: ->
		msg = @props.msg
		linkified = @linkify(msg.msg)
		emotedMsg = @props.renderEmotes && Bem.applyEmotesToStr(linkified) || linkified
		nickColor = msg.nick && wutColors.getUserColor(msg.nick)
		rowClass =
			"msg-row": true
			"squee": msg.isSquee
			"self": msg.isSelf
			"highlighted": @props.highlighted
			"seoncdaryHighlighted": @props.seoncdaryHighlighted
		rowClass[msg.emote] = true if msg.emote
		msgBody =
			switch msg.emote
				when "request"
					<span>
						<span className="user" style={color: nickColor}>{msg.nick}</span>
						requests 
						<span dangerouslySetInnerHTML={{__html: emotedMsg}}/>
					</span>
				when "drink"
					<span>Drink <span dangerouslySetInnerHTML={{__html: emotedMsg}}/></span>
				when "system"
					<span dangerouslySetInnerHTML={{__html: emotedMsg}}/>
				when "poll"
					<span className="user" style={color: nickColor}>{msg.nick}</span>
					<span> has created a new poll: <span dangerouslySetInnerHTML={{__html: emotedMsg}}/></span>
				when "tabout"
					<span>▽ ({msg.msg}) New messages since you tabbed out ▽</span>
				else
					<span>
						<span className="user" title={"click to highlight all messages by #{msg.nick}"} onClick={@props.onSelectNick?.bind(null, msg.nick)} style={color: nickColor}>{msg.nick}&nbsp;</span>
						<span className={"quote" if msg.msg.indexOf("&gt;") == 0} dangerouslySetInnerHTML={{__html: emotedMsg}}/>
					</span>

		<div className={cx(rowClass)}>
			{msgBody}
			{<TimeAgo className="timestamp" date={(new Date(msg.timestamp)).getTime()} /> if msg.timestamp}
		</div>
