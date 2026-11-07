local EVENT = Tablet_GetEventPrefix()

local function requestList()
    TriggerServerEvent(EVENT .. 'requestlist')
end

RegisterCommand(Config.Command, requestList, false)

if Config.OpenKey then
    RegisterKeyMapping(Config.Command, 'Open robbery tablet', 'keyboard', Config.OpenKey)
end

function Tablet_RequestList()
    requestList()
end