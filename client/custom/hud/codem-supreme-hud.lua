-- [INFO] codem-supreme-hud HUD bridge; inactive unless Config.Hud is 'codem-supreme-hud'.
Hud = Hud or {}
if Config.Hud ~= 'codem-supreme-hud' then
    return
end

function Hud.SetVisible(visible)
    if visible then
        exports['codem-supreme-hud']:ShowHud()
    else
        exports['codem-supreme-hud']:HideHud()
    end
end

function Hud.IsHidden()
    return exports['codem-supreme-hud']:IsHudHidden() == true
end