window.ipc = require('ipc')
window.nativeApp = require('remote').require('app');

require('web-frame').setSpellCheckProvider("en-US", true, {
	spellCheck: function(text) {
		console.log("Spellcheck", text)
		return !(require('spellchecker').isMisspelled(text));
	}
});




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
