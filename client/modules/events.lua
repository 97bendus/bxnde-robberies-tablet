local EVENT = Tablet_GetEventPrefix()

RegisterNetEvent(EVENT .. 'opentablet', function()
    Tablet_RequestList()
end)

RegisterNetEvent(EVENT .. 'receiveList', function(payload)
    if TabletCountdown.active then return end

    local function reveal()
        SetNuiFocus(true, true)

        local steps, stepMs = Tablet_GetCinematicTiming()

        SendNUIMessage({
            action = 'open',
            scene = TabletScene.active,
            payload = type(payload) == 'table' and payload or {},
            locale = GetLocale(),
            countdown = { steps = steps, stepMs = stepMs },
            servername = Config.servername,
            serverlogo = Config.serverlogo
        })
    end

    if TabletScene.state == 'idle'
        and TabletScene.Eligible()
        and TabletScene.Start(reveal) then
        return
    end

    reveal()
end)

RegisterNetEvent(EVENT .. 'notify', function(message, kind)
    Notify(message, nil, kind)
end)