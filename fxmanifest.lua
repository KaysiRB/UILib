fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Novaa'
description 'UILib - Standalone NUI Menu Framework v2.0'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/*'
}

client_scripts {
    'client/lib/main.lua',
    'client/mainClient.lua'
}

server_scripts {
    'server/mainServer.lua'
}

exports {
    'CreateMenu',
    'Button',
    'Toggle',
    'Slider',
    'SubMenu',
    'PlayerList'
}