var React = require("react")
let SuperAgent = require("superagent")
let jsonp = require("superagent-jsonp")

let embed_providers = [{
	match: /(.*\.)?deviantart\.com/i,
	url: "http://backend.deviantart.com/oembed",
	format: "jsonp"
}, {
	match: /(derpicdn|trixiebooru|derpiboo)\.(ru|org|net)/i,
	url: "https://derpiboo.ru/oembed.json"
}]

module.exports = class LinkEmbed extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			title: props.url
		}

		if(!props.embedImages) {
			// do no further lookup
		} else if(props.url.match(/\.(jpg|jpeg|png|gif|gifv|webm|bmp)$/gi)) {
			this.state.thumbnail_url = props.url.replace(".webm",".gif").replace(".gifv", ".gif")
		} else if(props.url.match(/gfycat\.com/gi)) {
			this.state.thumbnail_url = props.url.replace("gfycat.com", "giant.gfycat.com") + ".gif"
		} else {
			for (let provider of embed_providers) {
				let regex = provider.match
				if(regex.test(props.url)) {
					let url = provider.url
					let format = provider.format || "json"
					let req = SuperAgent.get(`${url}?maxheight=150&format=${format}&url=${window.encodeURIComponent(this.props.url)}`)
					if(format == "jsonp") {
						req.use(jsonp)
					}
					req.end(function(err, res) {
						if(err || !res) {
							console.error(err)
							return
						}
						var data = res.body
						if (data) {
							this.setState({
								thumbnail_url: data.thumbnail_url,
								title: `${data.provider_name} - ${data.title}`
							})
						}
					}.bind(this))
					break
				}
			}
		}
	}

	render() {
		let url = this.props.url,
			thumbnail_url = this.state.thumbnail_url

		if(thumbnail_url) {
			return (
				<a title={this.state.title} className='thumbnail' href={url} target='_blank'>
					<img src={thumbnail_url}/>
				</a>
			)
		} else {
			return <a href={url} target='_blank'>{url}</a>
		}
	}
}
