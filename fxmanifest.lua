fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'UILib'

client_scripts {
    'client/lib/main.lua',
    'client/mainClient.lua'
}

ui_page 'html/index.html'
files { 'html/*' }

exports {
    'CreateMenu', 'Button', 'Toggle', 'SubMenu', 
    'Finish', 'Close', 'PlayerList'
}