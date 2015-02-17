Bem = require "./berrymotes"
$ = require "jQuery"
cx = React.addons.classSet

Poll = React.createClass
	displayName: 'Poll'

	componentDidMount: ->
		return unless Bem.doneLoading
		Bem.postEmoteEffects($(@getDOMNode()))

	componentDidUpdate: ->
		return unless Bem.doneLoading
		Bem.postEmoteEffects($(@getDOMNode()))

	render: ->
		poll = @props.poll
		<div className="panel panel-default polls">
			<div className="panel-heading">{Bem.applyEmotesToStr(poll.title)}</div>
			<div className="panel-body">
				<ul>
					{poll.options.map (option, i) =>
						voteClass =
							votes: true
							voted: poll.voted == i
						<li>
							<span className={cx(voteClass)} onClick={@props.onVote.bind(null, i)}>{poll.votes[i]}</span>{Bem.applyEmotesToStr(option)}
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