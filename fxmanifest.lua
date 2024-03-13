fx_version 'cerulean'
lua54 'yes'
game 'gta5'

name 'bnl-housing'
author 'Boris'
version '0.0.1'
repository 'https://github.com/borisnliscool/bnl-housing'
description 'A player property system for FiveM'

dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql',
}

ui_page 'src/web/build/index.html'

files {
    'src/bridge/**/client.lua',
    'data/**/*.lua',
    'locales/*.json',
    'src/web/build/index.html',
    'src/web/build/**/*',
    'stream/*.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'shellprops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv10.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv2.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv3.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv4.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv5.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv7.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv8.ytyp'
data_file 'DLC_ITYP_REQUEST' 'shellpropsv9.ytyp'

client_scripts {
    'src/client/**/*.lua',
    'src/specialprops/**/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/server/classes/*.lua',
    'src/server/*.lua',
    'src/server/callbacks/*.lua',
    'src/specialprops/**/server.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'src/bridge/shared.lua',
    'src/shared/*.lua',
    'src/specialprops/**/shared.lua',
}
