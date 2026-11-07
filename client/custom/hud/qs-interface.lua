-- [INFO] qs-interface HUD bridge; inactive unless Config.Hud is 'qs-interface'.
Hud = Hud or {}
if Config.Hud ~= 'qs-interface' then
    return
end

function Hud.SetVisible(visible)
    exports['qs-interface']:ToggleHud(visible)
end