cx = require "classnames"
ReactDOM = require "react-dom"
Utils = require "./utils.jsx"

Poll = React.createClass
	displayName: 'Poll'

	render: ->
		poll = @props.poll
		<div className="panel panel-default polls">
			<div className="panel-heading">{Utils.componentizeString(poll.title)} ~ {poll.creator}</div>
			<div className="panel-body">
				<ul>
					{poll.options.map (option, i) =>
						voteClass =
							votes: true
							voted: poll.voted == i
						<li>
							<span className={cx(voteClass)} onClick={@props.onVote.bind(null, i)}>{poll.votes[i]}</span>
							{Utils.componentizeString(option)}
						</li>}
				</ul>
			</div>
		</div>

module.exports = React.createClass
	displayName: 'PollsModal'

	render: ->
		"{'inactive':poll.inactive, 'disable':poll.voted != undefined}"

		<div className="poll-list">
			{@props.polls.map((poll) => <Poll poll={poll} onVote={@props.onVote} />).reverse()}
		</div>
