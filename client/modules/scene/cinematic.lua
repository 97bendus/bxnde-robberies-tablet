local scene = SceneRuntime

local WAYPOINTS = {
    { a =  20, d = 1.7, h =  0.15, lz = 0.00, fov = 34 },                          -- hands (knuckles)
    { a =  55, d = 2.8, h =  0.50, lz = 0.20, fov = 42 },                          -- side, full body
    { a =  90, d = 1.9, h =  0.55, lz = 0.15, fov = 34 },                          -- wrist (watch)
    { a = 125, d = 3.0, h =  1.00, lz = 0.30, fov = 44 },                          -- behind, from above
    { a = 180, d = 2.8, h =  0.85, lz = 0.95, fov = 38, roll = 0, cut = false },   -- final second: smooth move behind the character
}

for i = 2, #WAYPOINTS do
    local diff = (WAYPOINTS[i].a - WAYPOINTS[i - 1].a + 180) % 360 - 180
    WAYPOINTS[i].a = WAYPOINTS[i - 1].a + diff
end

local ANIMS = {
    { at =    0, dict = 'anim@mp_player_intcelebrationmale@knuckle_crunch', name = 'knuckle_crunch',    dur = 1300 },
    { at = 1300, dict = 'anim@random@shop_clothes@watches',                 name = 'idle_a',            dur = 1300 },
    { at = 2600, dict = 'clothingtie',                                      name = 'try_tie_neutral_a', dur = 1100 },
    { at = 3500, dict = 'mp_masks@on_foot',                                 name = 'put_on_mask',       dur = 1300 },
}

local SLOWMO_STEPS = 2
local DOLLY        = 0.45
local BEAT_PUNCH   = 2.0
local BEAT_MS      = 200

local function ease(u)
    u = math.min(1.0, math.max(0.0, (u - 0.15) / 0.7))
    return u * u * (3.0 - 2.0 * u)
end

local function lerp(a, b, t) return a + (b - a) * t end
function TabletScene.Beat()
    scene.lastBeat = GetGameTimer()
end

function TabletScene.CineRun(count, interval)
    if TabletScene.state == 'closing' or TabletScene.state == 'cine' then return end

    CreateThread(function()
        local cfg = Config.Scene
        local cc  = cfg.Cinematic or {}
        local function enabled(key) return cc[key] ~= false end

        local timeout = GetGameTimer() + 3000
        while TabletScene.state == 'opening' and GetGameTimer() < timeout do Wait(50) end
        if TabletScene.wantClose or (TabletScene.state ~= 'idle' and TabletScene.state ~= 'open') then return end

        local ped = PlayerPedId()

        if TabletScene.state == 'idle' then
            scene.ped        = ped
            scene.wasRadar   = not IsRadarHidden()
            scene.wasFrozen  = IsEntityPositionFrozen(ped)
            scene.animLoaded = false
            if cfg.HideRadar then DisplayRadar(false) end
            ClearPedTasks(ped)

            local pos, rot = GetGameplayCamCoord(), GetGameplayCamRot(2)
            scene.cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
                pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, GetGameplayCamFov(), true, 2)
            SetCamActive(scene.cam, true)
            RenderScriptCams(true, false, 0, true, true)
            TabletScene.active = true
        else
            Scene_DeleteTabletProp()
            if IsEntityPlayingAnim(ped, cfg.Dict, cfg.Anim, 3) then StopAnimTask(ped, cfg.Dict, cfg.Anim, 2.5) end
        end

        FreezeEntityPosition(ped, true)
        scene.cineFrozen = true
        TabletScene.state = 'cine'
        local token = TabletScene.token

        local useAnims = enabled('Animations')
        scene.cineDicts = {}
        if useAnims then
            for _, a in ipairs(ANIMS) do
                RequestAnimDict(a.dict)
                scene.cineDicts[#scene.cineDicts + 1] = a.dict
            end
        end

        local origin  = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local right   = vector3(-forward.y, forward.x, 0.0)
        local dutch   = enabled('Dutch')

        local poses = {}
        count = math.max(1, count)
        for i = 1, count do
            local w = WAYPOINTS[math.min(#WAYPOINTS, math.ceil(i / count * #WAYPOINTS))]
            local rad = math.rad(w.a)
            local c, s = math.cos(rad), math.sin(rad)
            local pose = {
                x = origin.x + (forward.x * c + right.x * s) * w.d,
                y = origin.y + (forward.y * c + right.y * s) * w.d,
                z = origin.z + w.h,
                lx = origin.x, ly = origin.y, lz = origin.z + w.lz,
                fov = w.fov, roll = dutch and (w.roll or 0.0) or 0.0, cut = w.cut,
            }
            local dx, dy, dz = pose.lx - pose.x, pose.ly - pose.y, pose.lz - pose.z
            local len = math.sqrt(dx * dx + dy * dy + dz * dz)
            pose.dx, pose.dy, pose.dz = dx / len, dy / len, dz / len
            poses[i] = pose
        end

        local oldCam = scene.cam
        local sp, sr = GetCamCoord(oldCam), GetCamRot(oldCam, 2)
        local rx, rz = math.rad(sr.x), math.rad(sr.z)
        poses[0] = {
            x = sp.x, y = sp.y, z = sp.z,
            lx = sp.x + (-math.sin(rz) * math.cos(rx)) * 4.0,
            ly = sp.y + ( math.cos(rz) * math.cos(rx)) * 4.0,
            lz = sp.z + ( math.sin(rx)) * 4.0,
            fov = GetCamFov(oldCam), roll = sr.y,
        }

        local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', sp.x, sp.y, sp.z, sr.x, sr.y, sr.z, poses[0].fov, true, 2)
        SetCamNearClip(cam, 0.1)
        SetCamUseShallowDofMode(cam, false)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
        scene.cam = cam
        SetTimeout(300, function() DestroyCam(oldCam, false) end)

        local useGrade, redGrade = enabled('Grade'), false
        if useGrade then
            SetTimecycleModifier('cinema')
            SetTimecycleModifierStrength(0.8)
            scene.cineGrade = true
        end

        TabletHud.Hide()

        local useDof, useSlow, usePunch = enabled('Dof'), enabled('SlowMo'), enabled('BeatPunch')
        local timeScale = interval / 1000.0
        local slowScale = cc.SlowMoScale or 0.35
        local nextAnim = 1

        local steps = #poses
        local total = steps * interval
        local slowFrom = math.max(0, total - SLOWMO_STEPS * interval)
        local startedAt = GetGameTimer()

        while true do
            Wait(0)
            if TabletScene.token ~= token or TabletScene.state ~= 'cine' then return end

            local now     = GetGameTimer()
            local elapsed = math.min(now - startedAt, total)
            local idx     = math.min(steps - 1, math.floor(elapsed / interval))
            local u       = (elapsed - idx * interval) / interval
            local a, b    = poses[idx], poses[idx + 1]

            local px, py, pz, lx, ly, lz, fov, roll
            if b.cut then
                local drift = DOLLY * u
                px, py, pz = b.x + b.dx * drift, b.y + b.dy * drift, b.z + b.dz * drift
                lx, ly, lz = b.lx, b.ly, b.lz
                fov, roll  = b.fov - 1.5 * u, b.roll
            else
                local e = ease(u)
                px, py, pz = lerp(a.x, b.x, e), lerp(a.y, b.y, e), lerp(a.z, b.z, e)
                lx, ly, lz = lerp(a.lx, b.lx, e), lerp(a.ly, b.ly, e), lerp(a.lz, b.lz, e)
                fov, roll  = lerp(a.fov, b.fov, e), lerp(a.roll, b.roll, e)
            end

            if usePunch and scene.lastBeat then
                fov = fov - BEAT_PUNCH * math.max(0.0, 1.0 - (now - scene.lastBeat) / BEAT_MS)
            end

            local dx, dy, dz = lx - px, ly - py, lz - pz
            local pitch = math.deg(math.atan(dz, math.sqrt(dx * dx + dy * dy)))
            local yaw   = math.deg(math.atan(-dx, dy))
            SetCamCoord(cam, px, py, pz)
            SetCamRot(cam, pitch, roll, yaw, 2)
            SetCamFov(cam, fov)

            if useDof then
                local dist = #(vector3(px, py, pz) - origin)
                SetCamUseShallowDofMode(cam, true)
                SetCamNearDof(cam, math.max(0.1, dist - 1.5))
                SetCamFarDof(cam, dist + 2.2)
                SetCamDofStrength(cam, 0.5)
            end

            while useAnims and nextAnim <= #ANIMS and elapsed >= ANIMS[nextAnim].at * timeScale do
                local an = ANIMS[nextAnim]
                if HasAnimDictLoaded(an.dict) then
                    TaskPlayAnim(ped, an.dict, an.name, 4.0, -4.0, math.floor(an.dur * timeScale), 48, 0.0, false, false, false)
                end
                nextAnim = nextAnim + 1
            end

            if elapsed >= slowFrom then
                if useGrade and not redGrade then
                    redGrade = true
                    SetTimecycleModifier('REDMIST_blend')
                    SetTimecycleModifierStrength(0.5)
                end
                if useSlow then
                    scene.cineSlow = true
                    SetTimeScale(lerp(1.0, slowScale, math.min(1.0, (elapsed - slowFrom) / 400.0)))
                end
            end

            if elapsed >= total then return end
        end
    end)
end