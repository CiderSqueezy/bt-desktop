let React = require("react")
let cx = require("classnames")
// APNG is bad and just creates a global
let _APNG = require("apng-canvas")
let APNG = window.APNG

let Bem = require("./berrymotes.jsx")
let {EmoteParser} = require("emotes")
let parser = new EmoteParser()
const MAX_HEIGHT = 200

module.exports = class Emote extends React.Component {
	constructor(props) {
		super(props)
		var emoteIdentifier, originalString
		if(props.emoteId) {
			emoteIdentifier = props.emoteId
			originalString = props.emoteId
		} else {
			let emoteObject = parser.parse(props.emote)
			emoteIdentifier = emoteObject.emoteIdentifier
			originalString = emoteObject.originalString
		}
		this.state = {
			originalString,
			emoteIdentifier,
			emoteData: Bem.findEmote(emoteIdentifier)
		}
		Bem.on("update", this.onEmoteUpdate.bind(this))
	}

	onEmoteUpdate() {
		this.setState({
			emoteData: Bem.findEmote(this.state.emoteIdentifier)
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
		if(!emoteData) {
			return <span>{this.state.originalString}</span>
		} else {

			let title = `${(emoteData.names||[]).join(",")} from /r/${emoteData.sr}`
			let className = {
				"berrymotes": true,
				"nsfw": emoteData.nsfw
			}

			let scale = emoteData.height > MAX_HEIGHT ? MAX_HEIGHT/emoteData.height : 1

			let outerStyle = {
				transform: `scale(${scale})`,
				transformOrigin: "left top 0px",
				position: "absolute",
				top: 0,
				left: 0
			}

			let style  = {
				height: `${emoteData.height}px`,
				width: `${emoteData.width}px`,
				display: "inline-block",
				position: "relative",
				overflow: "hidden",
				backgroundPosition: (emoteData["background-position"] || ["0px", "0px"]).join(" "),
				backgroundImage: `url(${emoteData["background-image"]})`
			}

			let emoteNode = <span ref="emote" onClick={this.props.emoteSelected && this.props.emoteSelected.bind(this, this.props.emoteIdentifier)} className={cx(className)} title={title} style={style}/>
			if(scale < 1) {
				var outerWrapperStyle = {
					height: MAX_HEIGHT,
					width: emoteData.width * scale,
					position: "relative",
					display: "inline-block"
				}

				return (
					<span className="berrymotes-wrapper-outer" style={outerWrapperStyle}>
						<span className="berrymotes-wrapper" style={outerStyle}>
							{emoteNode}
						</span>
					</span>
				)
			} else {
				return emoteNode
			}
		}
	}
}
