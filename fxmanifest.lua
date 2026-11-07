fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'bxnde'
description 'bxnde-robberies-tablet'
version '1.0.0'

ui_page 'web/index.html'

shared_scripts {
    'shared/logger.lua',
    'shared/utils.lua',
    'config/main.lua'
}

client_scripts {
    'client/custom/notify/*.lua',
    'client/custom/hud/*.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/custom/framework/*.lua',
    'server/custom/inventory/*.lua',
    'server/custom/webhooks/main.lua',
    'server/main.lua'
}

files {
    'client/modules/**/*.lua',
    'locales/*.json',
    'web/index.html',
    'web/build/assets/*',
    'web/build/images/*'
}

dependency 'oxmysql'