module.exports = React.createClass

  displayName: 'Time-Ago',

  getDefaultProps: ->
    live: true

  componentDidMount: ->
    @tick(true) if @props.live

  tick: (refresh) ->
    return unless @isMounted()

    period = 1000

    t = (new Date(this.props.date)).valueOf()
    now = Date.now()
    seconds = Math.round(Math.abs(now-t)/1000)

    if seconds < 60*60
      period = 1000 * 60
    else if seconds < 60*60*24
      period = 1000 * 60 * 60
    else
      period = 0

    if !!period
      setTimeout(this.tick, period);

    if !refresh
      this.forceUpdate()

  render: ->
    t = (new Date(this.props.date)).valueOf()
    now = Date.now()
    seconds = Math.round(Math.abs(now-t)/1000)

    suffix = if t < now then 'ago' else 'from now'

    if seconds < 60*60
      content = Math.round(seconds/60)
      unit = 'm'
    else if seconds < 60*60*24
      content = Math.round(seconds/(60*60))
      unit = 'h'
    else if seconds < 60*60*24*7
      content = Math.round(seconds/(60*60*24))
      unit = 'd'
    else if seconds < 60*60*24*30
      content = Math.round(seconds/(60*60*24*7))
      unit = 'w'
    else if seconds < 60*60*24*365
      content = Math.round(seconds/(60*60*24*30))
      unit = 'month'
    else
      content = Math.round(seconds/(60*60*24*365))
      unit = 'yr'

    <span className={@props.className} style={@props.style} id={@props.id}>
      {if seconds < 60 then "now" else "#{content}#{unit} #{suffix}"}
    </span>
