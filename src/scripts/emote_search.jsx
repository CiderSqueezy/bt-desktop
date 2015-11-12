let React = require("react")
let _ = require("underscore")
let Bem = require("./berrymotes.jsx")
let Emote = require("./emote.jsx")

module.exports = class EmoteSearch extends React.Component {

	shouldComponentUpdate(nextProps) {
		return nextProps.search != this.props.search
	}

	render() {
		let results = Bem.searchEmotes(this.props.search)
		return (
			<div className="emote-search">
				{_.first(results,100).map((emoteName) => {
					return <Emote emoteSelected={this.props.emoteSelected.bind(null, emoteName)} key={emoteName} emoteId={emoteName}/>
				})}
			</div>
		)
	}
}
