var app = require('app');  // Module to control application life.
var BrowserWindow = require('browser-window');  // Module to create native browser window.
var shell = require('shell');
var Menu = require('menu');



// Report crashes to our server.
require('crash-reporter').start();

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow, tcWindow = null;

// Quit when all windows are closed.
app.on('window-all-closed', function() {
	app.quit();
});

// This method will be called when atom-shell has done everything
// initialization and ready for creating browser windows.
app.on('ready', function() {
	var template = [{
		label: 'BerryTube',
		submenu: [
		{
			label: 'About BerryTube',
			selector: 'orderFrontStandardAboutPanel:'
		},
		{
			type: 'separator'
		},
		{
			label: 'Services',
			submenu: []
		},
		{
			type: 'separator'
		},
		{
			label: 'Hide Atom Shell',
			accelerator: 'Command+H',
			selector: 'hide:'
		},
		{
			label: 'Hide Others',
			accelerator: 'Command+Shift+H',
			selector: 'hideOtherApplications:'
		},
		{
			label: 'Show All',
			selector: 'unhideAllApplications:'
		},
		{
			type: 'separator'
		},
		{
			label: 'Quit',
			accelerator: 'Command+Q',
			click: function() { app.quit(); }
		},
		]
	},
	{
		label: 'Edit',
		submenu: [
		{
			label: 'Undo',
			accelerator: 'Command+Z',
			selector: 'undo:'
		},
		{
			label: 'Redo',
			accelerator: 'Shift+Command+Z',
			selector: 'redo:'
		},
		{
			type: 'separator'
		},
		{
			label: 'Cut',
			accelerator: 'Command+X',
			selector: 'cut:'
		},
		{
			label: 'Copy',
			accelerator: 'Command+C',
			selector: 'copy:'
		},
		{
			label: 'Paste',
			accelerator: 'Command+V',
			selector: 'paste:'
		},
		{
			label: 'Select All',
			accelerator: 'Command+A',
			selector: 'selectAll:'
		},
		]
	},
	{
		label: 'View',
		submenu: [
		{
			label: 'Reload',
			accelerator: 'Command+R',
			click: function() { BrowserWindow.getFocusedWindow().reloadIgnoringCache(); }
		},
		{
			label: 'Toggle DevTools',
			accelerator: 'Alt+Command+I',
			click: function() { BrowserWindow.getFocusedWindow().toggleDevTools(); }
		},
		]
	},
	{
		label: 'Window',
		submenu: [
		{
			label: 'Minimize',
			accelerator: 'Command+M',
			selector: 'performMiniaturize:'
		},
		{
			label: 'Close',
			accelerator: 'Command+W',
			selector: 'performClose:'
		}
		]
	}];

	var menu = Menu.buildFromTemplate(template);

	Menu.setApplicationMenu(menu); // Must be called within app.on('ready', function(){ ... });


	// Create the browser window.
	mainWindow = new BrowserWindow({
		width: 960,
		height: 800,
		center: true,
		frame: false,
		"auto-hide-menu-bar": true
	});

	mainWindow.webContents.on('new-window', function(e, url) {
		console.log("NEW WINDOW", e, url)
		e.preventDefault();
		shell.openExternal(url);
	});
	
	// and load the index.html of the app.
	mainWindow.loadUrl('file://' + __dirname + '/index.html');
	// mainWindow.loadUrl("http://localhost:8080/");
	// mainWindow.loadUrl("http://bt-desktop.cidersqueezy.com/");


	mainWindow.on('blur', function(e) {
		mainWindow.webContents.send('blur');
	});

	mainWindow.on('focus', function(e) {
		mainWindow.webContents.send('focus');
	});

	// Emitted when the window is closed.
	mainWindow.on('closed', function() {
		// Dereference the window object, usually you would store windows
		// in an array if your app supports multi windows, this is the time
		// when you should delete the corresponding element.
		mainWindow = null;
	});


	// tcWindow = new BrowserWindow({
	// 	width: 960,
	// 	height: 590,
	// 	'web-preferences':{
	// 		'plugins': true
	// 	},
	// 	frame: false,
	// 	"auto-hide-menu-bar": true
	// });
	// tcWindow.webContents.on('new-window', function(e, url) {
	// 	e.preventDefault();
	// });
	// tcWindow.webContents.on('did-finish-load', function(e, url) {
	// 	tcWindow.webContents.insertCSS("#left_block, html, body, #tinychat, #tinychat_sub, #wrapper, #page, #container, #room, #chat {width: 100% !important; height: 100% !important; box-sizing: border-box; margin: 0; padding: 0 !important;} #iframe_ad, #header, #room_header, #share-bar, #footer {display: none;} body {width: calc(100% + 282px) !important; overflow: hidden; left: -8px; position: relative; top: -12px; height: calc(100% + 93px) !important; } body:after {content: ''; position: absolute; top: 0; left: 240px; height: 54px; width: calc(100% - 576px); -webkit-app-region: drag; cursor: move;}");
	// });
	// tcWindow.loadUrl("http://tinychat.com/berrytube");
	// tcWindow.on('closed', function() {
	// 	tcWindow = null;
	// });

});
