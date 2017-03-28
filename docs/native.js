if(window.require) {
	window.ipc = require("ipc")
	window.nativeApp = require("remote").require("app")
	var spellchecker = require("remote").require("spellchecker")

	require("web-frame").setSpellCheckProvider("en-US", false, {
		spellCheck: function(text) {
			console.log("Spellcheck", text)
			return !spellchecker.isMisspelled(text)
		}
	})

	// var remote = require('remote');
	// var Menu = remote.require('menu');
	// var MenuItem = remote.require('menu-item');

	// var menu = new Menu();

	// window.addEventListener('contextmenu', function (e) {
	//   e.preventDefault();
	//   menu.popup(remote.getCurrentWindow());
	// }, false);
	//
	//
}
