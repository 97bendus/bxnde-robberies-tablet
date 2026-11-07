local scene = SceneRuntime

function Scene_RestoreWorld(instant)
    local cfg = Config.Scene
    local ped = scene.ped or PlayerPedId()

    Scene_DeleteTabletProp()

    if DoesEntityExist(ped) then
        if IsEntityPlayingAnim(ped, cfg.Dict, cfg.Anim, 3) then
            StopAnimTask(ped, cfg.Dict, cfg.Anim, instant and 8.0 or 2.5)
        end

        if (cfg.Freeze or scene.cineFrozen) and not scene.wasFrozen then
            FreezeEntityPosition(ped, false)
        end
    end

    if scene.animLoaded then RemoveAnimDict(cfg.Dict) end
    if cfg.HideRadar and scene.wasRadar then DisplayRadar(true) end

    TabletHud.Show()

    if scene.cineGrade then ClearTimecycleModifier() end
    if scene.cineSlow then SetTimeScale(1.0) end

    if scene.cineDicts then
        if DoesEntityExist(ped) then ClearPedSecondaryTask(ped) end
        for _, dict in ipairs(scene.cineDicts) do
            RemoveAnimDict(dict)
        end
    end

    scene.lastBeat = nil

    if scene.cam then
        local duration = instant and 0 or Scene_InterpOut()
        RenderScriptCams(false, not instant, duration, true, true)

        local cam, camStart = scene.cam, scene.camStart
        SetTimeout(instant and 50 or (duration + 150), function()
            if cam and DoesCamExist(cam) then DestroyCam(cam, false) end
            if camStart and DoesCamExist(camStart) then DestroyCam(camStart, false) end
        end)
    end

    scene.ped = nil
    scene.cam = nil
    scene.camStart = nil
    scene.animLoaded = false
    scene.cineFrozen = false
    scene.cineGrade = false
    scene.cineSlow = false
    scene.cineDicts = nil
    scene.noProp = false
    scene.cameraPosition = nil
    scene.cameraRight = nil

    TabletScene.active = false
end

function TabletScene.Stop(instant)
    if TabletScene.state == 'idle' or TabletScene.state == 'closing' then return end

    if TabletScene.state == 'opening' and not instant then
        TabletScene.wantClose = true
        return
    end

    TabletScene.state = 'closing'
    TabletScene.token = TabletScene.token + 1

    CreateThread(function()
        Scene_RestoreWorld(instant)
        if not instant then Wait(Scene_InterpOut() + 200) end
        TabletScene.state = 'idle'
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    SetNuiFocus(false, false)

    if TabletScene.state ~= 'idle' then
        TabletScene.token = TabletScene.token + 1
        Scene_RestoreWorld(true)
        TabletScene.state = 'idle'
    end
end)