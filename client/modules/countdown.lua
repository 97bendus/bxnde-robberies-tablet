local EVENT = Tablet_GetEventPrefix()

local function cancelCountdown()
    if not TabletCountdown.active then return end

    TabletCountdown.active = false
    TabletCountdown.token = TabletCountdown.token + 1

    SendNUIMessage({ action = 'cancelCountdown' })
    Notify(Translate('cancelled'), nil, 'info')
    TabletScene.Stop()
end

function TabletCountdown_Start()
    if TabletCountdown.active then return false end

    TabletCountdown.active = true
    TabletCountdown.token = TabletCountdown.token + 1

    local token = TabletCountdown.token
    local steps, stepMs = Tablet_GetCinematicTiming()
    local deadline = GetGameTimer() + steps * stepMs + 4000

    SetNuiFocus(false, false)
    TabletScene.DropProp()

    CreateThread(function()
        while TabletCountdown.active
            and TabletCountdown.token == token
            and GetGameTimer() < deadline do

            Wait(0)
            DisableAllControlActions(0)
            EnableControlAction(0, 177, true)

            if IsEntityDead(PlayerPedId())
                or IsControlJustPressed(0, 177)
                or IsDisabledControlJustPressed(0, 177) then
                cancelCountdown()
                return
            end
        end

        if TabletCountdown.active and TabletCountdown.token == token then
            TabletCountdown.active = false
            TabletScene.Stop()
        end
    end)

    return true
end

function TabletCountdown_Cancel()
    cancelCountdown()
end

function TabletCountdown_Finish()
    TabletCountdown.active = false
    TabletCountdown.token = TabletCountdown.token + 1
end