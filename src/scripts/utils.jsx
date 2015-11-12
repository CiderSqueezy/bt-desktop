let Emote = require("./emote.jsx")

let mapAlternate = function(array, fn1, fn2, thisArg) {
	var fn = fn1, output = []
	for (var i=0; i<array.length; i++){
		if(array[i] && array[i].length !== 0) {
			output[i] = fn.call(thisArg, array[i], i, array)
		}
		fn = fn === fn1 ? fn2 : fn1
	}
	return output
}

let emoteRegex = /(\[\]\(\/[\w:!#\/]+[-\w!]*[^)]*\))/gi

let Utils = {
	mapAlternate: mapAlternate,
	componentizeString: function(s) {
		let ret = mapAlternate(s.split(emoteRegex), function(s) {
			return s
		}, function(s,i) {
			return <Emote emote={s} key={`emote${i}}`}/>
		})
		return ret.length == 1 ? ret[0] : ret
	}
}

module.exports = Utils
