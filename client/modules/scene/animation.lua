function Scene_LoadAnimation(dict)
    if not DoesAnimDictExist(dict) then return false end

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do Wait(0) end

    return HasAnimDictLoaded(dict)
end

function Scene_PlayTabletAnimation(ped)
    local cfg = Config.Scene
    TaskPlayAnim(ped, cfg.Dict, cfg.Anim, 4.0, 4.0, -1, 49, 0.0, false, false, false)
end