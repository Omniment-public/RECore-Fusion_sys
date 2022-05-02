require(["nbextensions/snippets_menu/main"], function(snippets_menu) {
	console.log('Loading `snippets_menu` customizations from `custom.js`');
	var snip_recore = {
		'name' : 'RECore',
		'sub-menu' : [
			{
				'name' : 'Insert pyREcore Library',
				'snippet' : ["from pyrecore import *","","recore = RECore()","",],
			},
		],
	};
	snippets_menu.options['menus'].push(snippets_menu.default_menus[0]);
	snippets_menu.options['menus'].push(snip_recore);
	console.log('Loaded`snipetts_menu` customizations from `custom.js`');
});

