cx = require "classnames"
ReactDOM = require "react-dom"

module.exports = React.createClass
	displayName: 'Playlist'
	rowHeight: 28 + 3

	componentDidMount: ->
		@scrollToActive(true)

	componentDidUpdate: ->
		@scrollToActive()

	# shouldComponentUpdate: (nextProps, nextState) ->
	# 	nextProps.currentVideo.videoid != @props.currentVideo.videoid || nextProps.playlist

	scrollToActive: (force) ->
		scroller = @refs.scroller
		curScrollTop = scroller.scrollTop
		scrollerHeight = ReactDOM.findDOMNode(this).clientHeight
		newScrollTop = (@activeRow * @rowHeight) + @rowHeight/2 - scrollerHeight/2 + 3

		if force || (newScrollTop >= curScrollTop - scrollerHeight/2 && newScrollTop <= curScrollTop + scrollerHeight/2)
			scroller.scrollTop = newScrollTop

	render: ->
		activeRow = 0

		rows = @props.playlist.map (video, i) =>
			rowClass =
				active: @props.currentVideo && video.videoid == @props.currentVideo.videoid
				volatile: video.volat
			activeRow = i if rowClass.active
			<li className={cx(rowClass)} key={video.videoid}>{decodeURIComponent(video.videotitle.replace(/&amp;/gi, "&"))}</li>

		@activeRow = activeRow

		<div ref="scroller" className="playlist">
			<ul>{rows}</ul>
		</div>
