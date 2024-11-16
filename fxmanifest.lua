fx_version 'cerulean'
game 'gta5'

description 'GLD-Recycling - ESX/QB Recycling System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'bridge/bridge.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}


lua54 'yes'