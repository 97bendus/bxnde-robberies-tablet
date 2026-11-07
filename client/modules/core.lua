TabletScene = TabletScene or {
    state = 'idle',
    active = false,
    token = 0,
    wantClose = false
}

TabletCountdown = {
    active = false,
    token = 0
}

local EVENT = 'bxnde-robberies-tablet:'

function Tablet_GetEventPrefix()
    return EVENT
end

function Tablet_GetCinematicTiming()
    local cinematic = Config.Scene and Config.Scene.Cinematic or {}
    local steps = math.max(1, math.floor(tonumber(cinematic.Steps) or 5))
    local stepMs = math.max(500, math.floor(tonumber(cinematic.StepMs) or 1000))
    return steps, stepMs
end