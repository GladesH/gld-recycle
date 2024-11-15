fx_version 'cerulean'
game 'gta5'

description 'GLD la mains verte'
version '1.0.0'

shared_script 'config.lua'
client_script 'client/client.lua'
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

lua54 'yes'