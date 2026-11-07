-- [INFO] jg-hud HUD bridge; inactive unless Config.Hud is 'jg-hud'.
Hud = Hud or {}
if Config.Hud ~= 'jg-hud' then
    return
end

function Hud.SetVisible(visible)
    exports['jg-hud']:toggleHud(visible)
end