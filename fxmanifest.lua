fx_version      'cerulean'
lua54           'yes'
game            'gta5'

name            'bnl-housing'
author          'Boris'
version         '1.0.0'
repository      ''
description     'A free and open source player property script for FiveM'

dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql',
}

files {
    'src/client/html/index.html',
    'src/client/html/main.js',
    'src/client/html/audio/*.mp3',

    'locales/*.json',
    'data/*.lua',
}

ui_page 'src/client/html/index.html'

client_scripts {
    'src/client/cl_main.lua',
    'src/client/cl_func.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'src/server/sv_main.lua',
    'src/server/sv_func.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'src/shared/sh_main.lua',
}