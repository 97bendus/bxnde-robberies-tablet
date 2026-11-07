-- [INFO] esx_hud HUD bridge; inactive unless Config.Hud is 'esx_hud'.
Hud = Hud or {}
if Config.Hud ~= 'esx_hud' then
    return
end

function Hud.SetVisible(visible)
    exports['esx_hud']:HudToggle(visible)
end