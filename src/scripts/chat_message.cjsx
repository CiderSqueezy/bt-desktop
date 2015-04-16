
nickColors = ["#49017a","#b24d0e","#ef02df","#037715","#bf095b","#db0493","#78a30b","#960f1c","#54057f","#d30ec3","#014789","#8a960c","#8c1c05","#95b211","#02547c","#510d89","#ba7310","#687504","#4b960d","#a50047","#9307c1","#050266","#db0f7f","#dd6b00","#b613f2","#15037a","#429b0f","#5d7c07","#018c75","#120184","#990738","#c40de0","#c94900","#9208c9","#09994c","#010d7f","#014f87","#a8033f","#a808d1","#aa113a","#f2df0c","#ed1794","#e50bb2","#8c2005","#80a00b","#259b0a","#c6a500","#017c60","#11af4b","#c15e0d","#008957","#b5104f","#c912c0","#031860","#a53b0d","#208205","#079632","#190c8e","#a30015","#410e93","#017c07","#c40d99","#0e9115","#0a6f93","#a5040a","#015e6b","#08a367","#110684","#004c63","#ed10d3","#043c8c","#0d5e91","#990d2e","#059113","#0d0075","#0e7205","#c1136d","#13960f","#10a556","#840337","#1d9102","#368704","#0b0766","#084868","#a512ce","#d3aa15","#89090b","#4b0584","#072291","#018767","#058405","#4e8402","#389101","#290689","#e20fcd","#008e1c","#04894f","#b20acc","#0b0d8c","#001e72","#0a3277","#a02709","#0da319","#026575","#d3046f","#2f0487","#eded04","#360770","#bc005b","#ba6805","#03586d","#03723e","#033675","#1d9b0f","#d8ca06","#1a0989","#090b75","#c807ea","#db5213","#cfd60a","#0a823c","#6e9601","#7a9e06","#e214b2","#00727c","#ba5e12","#e506c4","#a50401","#f7dc13","#4d8e0c","#010e5e","#a3370d","#728e02","#004872","#ce1283","#2d0289","#1b7001","#ed12c5","#660a93","#33af11","#cc1287","#d108d8","#2e026d","#8e0525","#338905","#892202","#0e9e2f","#0d9992","#b217ef","#207200","#07347c","#0f9b7f","#088c53","#a30fdd","#d1b70e","#410e93","#063068","#c4097c","#0f0b75","#088e59","#d36115","#e00bab","#088e2a","#0ea587","#2f7205","#00964b","#a00b15","#086363","#23028e","#028928","#3f0ba0","#0c006b","#010359","#002c5b","#a8033d","#018703","#ed04e1","#3f008c","#079e11","#e0ac00","#ccb102","#c902bc","#c61199","#e04d04","#190187","#069b10","#0daa7b","#089360","#bc035d","#b7650e","#0c876a","#a82508","#379b09","#4e9b0a","#08875a","#18096b","#9601bf","#048729","#12a308","#047a6c","#70a50d","#07488e","#0f995b","#d30c73","#2e0384","#05186b","#34a00c","#049613","#43a80d","#687504","#030668","#a50e2f","#a50646","#4b0b7c","#0a006b","#022c63","#a109bc","#610096","#b55e12","#ea07e3","#9e2d0b","#08397c","#0d4589","#d1a20a","#4a0870","#698709","#e25a0b","#0a9115","#d6047e","#0b0072","#ad1120","#b2470e","#a110d1","#a704d8","#f9ea18","#7e9b0c","#048784","#03097a","#02376d","#078c23","#dba40d","#c708d8","#ce08c4","#04961c","#450e8e","#04195e","#e4e812","#057560","#b23005","#017f74","#487f08","#b77503","#009316","#aa2d0a","#0d9b7f","#0c478e"]

Bem = require "./berrymotes"
TimeAgo = require "./timeago"
$ = require "jquery"
cx = React.addons.classSet
wutColors = require "./wutcolors"


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
		nextProps.renderEmotes != @props.renderEmotes || nextProps.highlighted != @props.highlighted || nextProps.msg != @props.msg

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
						<span className="user" title={"click to highlight all messages by #{msg.nick}"} onClick={@props.onSelectNick.bind(null, msg.nick)} style={color: nickColor}>{msg.nick}&nbsp;</span>
						<span className={"quote" if msg.msg.indexOf("&gt;") == 0} dangerouslySetInnerHTML={{__html: emotedMsg}}/>
					</span>

		<div className={cx(rowClass)}>
			{msgBody}
			{<TimeAgo className="timestamp" date={(new Date(msg.timestamp)).getTime()} /> if msg.timestamp}
		</div>
