SceneRuntime = SceneRuntime or {
    ped = nil,
    cam = nil,
    camStart = nil,
    prop = nil,
    animLoaded = false,
    wasRadar = true,
    wasFrozen = false,
    cineFrozen = false,
    cineGrade = false,
    cineSlow = false,
    cineDicts = nil,
    noProp = false,
    lastBeat = nil,
    cameraPosition = nil,
    cameraRight = nil
}

local DEFAULT_INTERP = 1400

function Scene_InterpIn()
    return (Config.Scene.Camera and Config.Scene.Camera.InterpIn) or DEFAULT_INTERP
end

function Scene_InterpOut()
    return (Config.Scene.Camera and Config.Scene.Camera.InterpOut) or DEFAULT_INTERP
end

function Scene_LoadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) then return nil end

    RequestModel(hash)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(0) end

    return HasModelLoaded(hash) and hash or nil
end

function TabletScene.Eligible()
    local cfg = Config.Scene or {}
    if not cfg.Enabled then return false end

    local ped = PlayerPedId()
    return not (
        IsEntityDead(ped)
        or IsPedInAnyVehicle(ped, false)
        or IsPedRagdoll(ped)
        or IsPedSwimming(ped)
        or IsPedFalling(ped)
        or IsPedClimbing(ped)
        or IsPedCuffed(ped)
    )
end