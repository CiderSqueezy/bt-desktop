let React = require("react")
let cx = require("classnames")
// APNG is bad and just creates a global
let _APNG = require("apng-canvas")
let APNG = window.APNG

let Bem = require("./berrymotes.jsx")
let {EmoteParser, EmoteHtml} = require("emotes")
let parser = new EmoteParser()
let html = new EmoteHtml(Bem.map)
const MAX_HEIGHT = 200

module.exports = class Emote extends React.Component {
	constructor(props) {
		super(props)
		var emoteIdentifier, originalString, htmlOutputData
		// emoteId will be set when this is used via search results
		if(props.emoteId) {
			emoteIdentifier = props.emoteId
			originalString = props.emoteId
			htmlOutputData = html.getEmoteHtmlMetadataForEmoteName(props.emoteId)
		} else {
			let emoteObject = parser.parse(props.emote)
			emoteIdentifier = emoteObject.emoteIdentifier
			originalString = emoteObject.originalString
			htmlOutputData = html.getEmoteHtmlMetadataForObject(emoteObject)
		}
		this.state = {
			originalString,
			emoteIdentifier,
			htmlOutputData,
			emoteData: Bem.findEmote(emoteIdentifier)
		}
		Bem.on("update", this.onEmoteUpdate.bind(this))
	}

	onEmoteUpdate() {
		this.setState({
			emoteData: Bem.findEmote(this.state.emoteIdentifier),
			htmlOutputData: html.getEmoteHtmlMetadataForEmoteName(this.state.emoteIdentifier)
		})
	}

	componentDidMount() {
		let node = this.refs.emote

		// @TODO only apply this if we actually dont have native apng support
		// also allow animate only on hover for emote search
		if(this.state.emoteData && this.state.emoteData.apng_url) {
			APNG.parseURL(this.state.emoteData.apng_url).then((anim) => {
				let canvas = document.createElement("canvas")
				canvas.width = anim.width
				canvas.height = anim.height

				let position = (this.state.emoteData["background-position"] || ["0px", "0px"])
				node.appendChild(canvas)

				node.style.backgroundImage = null
				canvas.style.position = "absolute"
				canvas.style.left = position[0]
				canvas.style.top = position[1]
				anim.addContext(canvas.getContext("2d"))
				anim.numPlays = Math.floor(60000/anim.playTime) // only run animations for 1min
				anim.rewind()
				anim.play()
			})
		}
	}

	render() {
		let emoteData = this.state.emoteData
		let htmlOutputData = this.state.htmlOutputData

		if(!htmlOutputData) {
			return <span>{this.state.originalString}</span>
		} else {

			// emotes have berryemote class set automatically, but we need berrymotes set as well
			let className = htmlOutputData.cssClassesForEmoteNode
			className['berrymotes'] = true

			// workaround for the emotes package not currently just setting the properties directly
			let emoteNodeStyle  = {}
			htmlOutputData.cssStylesForEmoteNode.forEach((st) => {
				emoteNodeStyle[st.propertyName] = st.propertyValue
			})

			let emoteNode = (
				<span ref="emote"
							onClick={this.props.emoteSelected && this.props.emoteSelected.bind(this, this.props.emoteIdentifier)}
							className={cx(className)}
							title={htmlOutputData.titleForEmoteNode}
							style={emoteNodeStyle}/>
			)

			// provide a wrapper node if necessary to apply the styles/classes from the 'parent node' info
			if (htmlOutputData.cssClassesForParentNode.length > 0 || htmlOutputData.cssStylesForParentNode.length > 0) {
				// workaround for the emotes package not currently just setting the properties directly
				let parentNodeStyle  = {}
				htmlOutputData.cssStylesForParentNode.forEach((st) => {
					parentNodeStyle[st.propertyName] = st.propertyValue
				})

				emoteNode = (
					<span className={cx(htmlOutputData.cssClassesForParentNode)} style={parentNodeStyle}>
						{emoteNode}
					</span>
				)
			}

			// provide wrapping to implement scaling down to meet MAX_HEIGHT requirement
			if (emoteData.height > MAX_HEIGHT) {
				let scale = MAX_HEIGHT/emoteData.height

				let outerWrapperStyle = {
					height: MAX_HEIGHT,
					width: emoteData.width * scale,
					position: "relative",
					display: "inline-block"
				}

				let innerWrapperStyle = {
					transform: `scale(${scale})`,
					transformOrigin: "left top 0px",
					position: "absolute",
					top: 0,
					left: 0
				}

				emoteNode = (
					<span className="berrymotes-wrapper-outer" style={outerWrapperStyle}>
						<span className="berrymotes-wrapper" style={innerWrapperStyle}>
							{emoteNode}
						</span>
					</span>
				)
			}

			return emoteNode
		}
	}
}
