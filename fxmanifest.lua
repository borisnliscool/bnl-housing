fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'bnl-housing'
author 'Boris'
version '0.0.1'
repository 'https://github.com/borisnliscool/bnl-housing'
description 'Simple player property system for FiveM'

dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql',
    'bnl-housing-shells',
}

files {
    'src/bridge/**/client.lua',
    'data/**/*.lua',
    'locales/*.json'
}

client_scripts {
    'src/client/**/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/server/classes/*.lua',
    'src/server/*.lua',
    'src/server/callbacks/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'src/bridge/shared.lua',
    'src/shared/*.lua',
}
