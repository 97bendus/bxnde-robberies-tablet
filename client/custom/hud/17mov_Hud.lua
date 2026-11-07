-- [INFO] 17mov_Hud HUD bridge; inactive unless Config.Hud is '17mov_Hud'.
Hud = Hud or {}
if Config.Hud ~= '17mov_Hud' then
    return
end

function Hud.SetVisible(visible)
    exports['17mov_Hud']:ToggleDisplay(visible)
end