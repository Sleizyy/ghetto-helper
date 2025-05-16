require 'lib.moonloader'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local function u8d(u8) return encoding.UTF8:decode(u8) end

function main()
    while not isSampAvailable() do wait(0) end
    
    sampRegisterChatCommand('sometext', function ()
        sampAddChatMessage(u8d'Привет', -1)
    end)

    while true do
        wait(0)
        
    end
end
