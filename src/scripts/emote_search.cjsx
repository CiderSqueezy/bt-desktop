_ = require "underscore"

# pulled from berrytube emote search
`var searchEmotes = function(term) {
    var searchResults = [];
    var distances = [];
    Bem.berryEmoteSearchTerm = term;

    if (!term) {
        var max = Bem.emotes.length;
        for (var i = 0; i < max; ++i) {
            var emote = Bem.emotes[i];
            if (Bem.isEmoteEligible(emote)) {
                searchResults.push(i);
            }
        }
    }
    else {
        var searchBits = term.split(' ');
        var tags = [];
        var srs = [];
        var terms = [];
        var scores = {};
        var srRegex = /^([-+]?sr:)|([-+]?[/]?r\/)/i;
        var tagRegex = /^[-+]/i;

        var sdrify = function (str) {
            return new RegExp('^' + str, 'i');
        }

        for (var i = 0; i < searchBits.length; ++i) {
            var bit = $.trim(searchBits[i]);
            if (bit.match(srRegex)) {
                var trim = bit.match(srRegex)[0].length;
                if (bit[0] == '-' || bit[0] == '+') {
                    srs.push({match: bit[0] != '-', sdr: sdrify(bit.substring(trim))});
                } else {
                    srs.push({match: true, sdr: sdrify(bit.substring(trim))});
                }
            } else if (bit.match(tagRegex)) {
                var trim = bit.match(tagRegex)[0].length;
                var tag = bit.substring(trim);
                var tagRegex = tag in Bem.tagRegexes ? sdrify(Bem.tagRegexes[tag]) : sdrify(tag);
                tags.push({match: bit[0] != '-', sdr: tagRegex});
            } else {
                terms.push({
                    any: new RegExp(bit, 'i'),
                    prefix: sdrify(bit),
                    exact: new RegExp('^' + bit + '$')
                });
            }
        }

        var max = Bem.emotes.length;
        for (var i = 0; i < max; ++i) {
            var emote = Bem.emotes[i];
            if (!Bem.isEmoteEligible(emote)) continue;
            var negated = false;
            for (var k = 0; k < srs.length; ++k) {
                var match = emote.sr.match(srs[k].sdr) || [];
                if (match.length != srs[k].match) {
                    negated = true;
                }
            }
            if (negated) continue;
            if (tags.length && (!emote.tags || !emote.tags.length)) continue;
            if (emote.tags && tags.length) {
                for (var j = 0; j < tags.length; ++j) {
                    var tagSearch = tags[j];
                    var match = false;
                    for (var k = 0; k < emote.tags.length; ++k) {
                        var tag = emote.tags[k];
                        var tagMatch = tag.match(tagSearch.sdr) || [];
                        if (tagMatch.length) {
                            match = true;
                        }
                    }
                    if (match != tagSearch.match) {
                        negated = true;
                        break;
                    }
                }
            }
            if (negated) continue;
            if (terms.length) {
                for (var j = 0; j < terms.length; ++j) {
                    var term = terms[j];
                    var match = false;
                    for (var k = 0; k < emote.names.length; ++k) {
                        var name = emote.names[k];
                        if (name.match(term.exact)) {
                            scores[i] = (scores[i] || 0.0) + 3;
                            match = true;
                        } else if (name.match(term.prefix)) {
                            scores[i] = (scores[i] || 0.0) + 2;
                            match = true;
                        } else if (name.match(term.any)) {
                            scores[i] = (scores[i] || 0.0) + 1;
                            match = true;
                        }
                    }
                    for (var k = 0; k < emote.tags.length; k++) {
                        var tag = emote.tags[k];
                        if (tag.match(term.exact)) {
                            scores[i] = (scores[i] || 0.0) + 0.3;
                            match = true;
                        } else if (tag.match(term.prefix)) {
                            scores[i] = (scores[i] || 0.0) + 0.2;
                            match = true;
                        } else if (tag.match(term.any)) {
                            scores[i] = (scores[i] || 0.0) + 0.1;
                            match = true;
                        }
                    }
                    if (!match) {
                        delete scores[i];
                        negated = true;
                        break;
                    }
                }
                if (negated) continue;
                //if (Bem.debug) console.log('Matched emote, score: ', emote, scores[i]);
            } else {
                scores[i] = 0;
            }
        }
        for (var id in scores) {
            searchResults.push(id);
        }
        searchResults.sort(function (a, b) {
            return scores[b] - scores[a];
        });
    }

    return searchResults;
};`

Emote = React.createClass
	displayName: 'Emote'

	componentDidMount: ->
		node = $(@getDOMNode())
		node.html(Bem.getEmoteHtml(Bem.emotes[@props.emoteId]))
		Bem.postEmoteEffects(node, true)

	render: ->
		<div onClick={@props.emoteSelected}/>

module.exports = React.createClass
	displayName: 'EmoteSearch'

	shouldComponentUpdate: (nextProps, nextState) ->
		nextProps.search != @props.search

	render: ->
		results = searchEmotes(@props.search)
		<div className="emote-search">
			{_.first(results,100).map (emoteId) =>
				<Emote emoteSelected={@props.emoteSelected.bind(this, emoteId)} key={emoteId} emoteId={emoteId}/>}
		</div>
