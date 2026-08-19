fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'weaponskins'
description 'Persistent weapon skins'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}
