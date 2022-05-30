fx_version      'cerulean'
lua54           'yes'
game            'gta5'

name            'bnl-housing'
author          'Boris'
version         '0.0.1'
repository      'https://github.com/borisnliscool/bnl-housing'
description     'Simple player property system'

dependencies {
	'/onesync',
	'ox_lib',
	'oxmysql',
}

shared_scripts {
	'@ox_lib/init.lua',
	'src/shared/sh_main.lua',
}

client_scripts {
	'src/client/cl_main.lua',
	'src/client/cl_functions.lua',
	'src/client/blipmanager.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',

	'src/server/sv_main.lua',
	'src/server/sv_functions.lua',
}

ui_page 'src/client/html/index.html'

files {
	'src/client/html/index.html',
	'src/client/html/main.js',
	'src/client/html/audio/*.mp3',

	'locales/*.json',
	'data/*.lua',
}
