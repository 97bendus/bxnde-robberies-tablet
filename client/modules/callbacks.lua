local EVENT = Tablet_GetEventPrefix()

RegisterNUICallback(EVENT .. 'ui:close', function(_, cb)
    SetNuiFocus(false, false)
    TabletCountdown_Cancel()
    TabletScene.Stop()
    cb({ ok = true })
end)

RegisterNUICallback(EVENT .. 'ui:refresh', function(_, cb)
    Tablet_RequestList()
    cb({ ok = true })
end)

RegisterNUICallback(EVENT .. 'ui:begin', function(data, cb)
    cb({ ok = true })

    local id = type(data) == 'table' and data.id
    if (type(id) ~= 'number' and type(id) ~= 'string') or TabletCountdown.active then
        return
    end

    TabletCountdown_Start()
end)

RegisterNUICallback(EVENT .. 'ui:beat', function(_, cb)
    cb({ ok = true })
    if TabletCountdown.active then TabletScene.Beat() end
end)

RegisterNUICallback(EVENT .. 'ui:cinestart', function(_, cb)
    cb({ ok = true })
    if not TabletCountdown.active then return end

    local steps, stepMs = Tablet_GetCinematicTiming()
    TabletScene.CineRun(steps, stepMs)
end)

RegisterNUICallback(EVENT .. 'ui:start', function(data, cb)
    cb({ ok = true })

    local id = type(data) == 'table' and data.id
    if not TabletCountdown.active then return end
    if type(id) ~= 'number' and type(id) ~= 'string' then return end

    TabletCountdown_Finish()
    TabletScene.Stop()

    local cinematic = Config.Scene and Config.Scene.Cinematic
    if not cinematic or cinematic.Impact ~= false then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
        SetTimeout(700, function()
            StopGameplayCamShaking(true)
        end)
    end

    if IsEntityDead(PlayerPedId()) then return end
    TriggerServerEvent(EVENT .. 'startrobbery', id)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    TabletCountdown_Finish()
    SetNuiFocus(false, false)
end)