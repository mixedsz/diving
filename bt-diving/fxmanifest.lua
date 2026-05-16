shared_scripts { '@FiniAC/fini_events.lua' }

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts { '@ox_lib/init.lua', '@es_extended/imports.lua', 'config.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua' }
client_scripts { '@PolyZone/client.lua', '@PolyZone/BoxZone.lua', '@PolyZone/EntityZone.lua', '@PolyZone/CircleZone.lua', '@PolyZone/ComboZone.lua', 'client/*.lua' }