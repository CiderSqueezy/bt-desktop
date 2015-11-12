hashCode = (str) ->
	hash = 0
	i = 0
	while i < str.length
		char = str.charCodeAt(i)
		hash = char + (hash << 6) + (hash << 16) - hash
		i++
	hash

window.wutUserColors = []
s = document.createElement("script")
s.src = "http://btc.berrytube.tv/wut/wutColors/usercolors.js"
document.body.appendChild(s)

module.exports =
	hashCode: hashCode
	getUserColor: (nick) ->
		if wutUserColors[nick]?
			wutUserColors[nick].color
		else
			hash = hashCode(nick)
			h = Math.abs(hash)%360
			s = Math.abs(hash)%25 + 70
			l = Math.abs(hash)%15 + 35
			a = 1
			"hsla("+h+","+s+"%,"+l+"%,"+a+")"
