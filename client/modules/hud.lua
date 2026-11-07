Hud = Hud or {}
Hud.SetVisible = Hud.SetVisible or function() end

TabletHud = TabletHud or { hidden = false }

local wasRadar = true
local wasHudHidden = false

function TabletHud.Hide()
    if TabletHud.hidden then return end

    TabletHud.hidden = true
    wasRadar = not IsRadarHidden()
    DisplayRadar(false)

    CreateThread(function()
        while TabletHud.hidden do
            HideHudAndRadarThisFrame()
            for component = 1, 22 do
                HideHudComponentThisFrame(component)
            end
            Wait(0)
        end
    end)

    if Config.Hud ~= 'none' then
        wasHudHidden = Hud.IsHidden and Hud.IsHidden() == true or false

        local ok, err = pcall(Hud.SetVisible, false)
        if not ok then
            print(('^1[%s] Hud.SetVisible(false) failed: %s^7'):format(
                Config.ResourceName or GetCurrentResourceName(), err
            ))
        end
    end
end

function TabletHud.Show()
    if not TabletHud.hidden then return end

    TabletHud.hidden = false

    if wasRadar then
        DisplayRadar(true)
    end

    if Config.Hud ~= 'none' and not wasHudHidden then
        local ok, err = pcall(Hud.SetVisible, true)
        if not ok then
            print(('^1[%s] Hud.SetVisible(true) failed: %s^7'):format(
                Config.ResourceName or GetCurrentResourceName(), err
            ))
        end
    end
end