function TabletScene.Start(onReady)
    if TabletScene.state ~= 'idle' or not TabletScene.Eligible() then return false end

    local cfg = Config.Scene
    local camCfg = cfg.Camera or {}

    TabletScene.state = 'opening'
    TabletScene.active = true
    TabletScene.wantClose = false
    TabletScene.token = TabletScene.token + 1

    local token = TabletScene.token

    CreateThread(function()
        local scene = SceneRuntime
        local ped = PlayerPedId()

        scene.ped = ped
        scene.wasRadar = not IsRadarHidden()
        scene.wasFrozen = IsEntityPositionFrozen(ped)
        scene.animLoaded = false
        scene.noProp = false

        if cfg.HideRadar then DisplayRadar(false) end

        if cfg.Freeze then
            ClearPedTasks(ped)
            FreezeEntityPosition(ped, true)
        end

        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

        local gamePos = GetGameplayCamCoord()
        local gameRot = GetGameplayCamRot(2)

        scene.camStart = CreateCamWithParams(
            'DEFAULT_SCRIPTED_CAMERA',
            gamePos.x, gamePos.y, gamePos.z,
            gameRot.x, gameRot.y, gameRot.z,
            GetGameplayCamFov(), true, 2
        )

        SetCamActive(scene.camStart, true)
        RenderScriptCams(true, false, 0, true, true)

        local origin = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local right = vector3(-forward.y, forward.x, 0.0)

        local camPos = vector3(
            origin.x + forward.x * (camCfg.Distance or 2.1),
            origin.y + forward.y * (camCfg.Distance or 2.1),
            origin.z + (camCfg.Height or 0.45)
        )

        local lookAt = vector3(
            origin.x + right.x * (camCfg.Side or 0.8),
            origin.y + right.y * (camCfg.Side or 0.8),
            origin.z + (camCfg.LookHeight or 0.35)
        )

        scene.cameraPosition = camPos
        scene.cameraRight = right

        scene.cam = CreateCamWithParams(
            'DEFAULT_SCRIPTED_CAMERA',
            camPos.x, camPos.y, camPos.z,
            0.0, 0.0, 0.0,
            camCfg.Fov or 42.0, true, 2
        )

        PointCamAtCoord(scene.cam, lookAt.x, lookAt.y, lookAt.z)

        if camCfg.Dof then
            SetCamUseShallowDofMode(scene.cam, true)
            SetCamNearDof(scene.cam, math.max(0.1, (camCfg.Distance or 2.1) - 1.0))
            SetCamFarDof(scene.cam, (camCfg.Distance or 2.1) + (camCfg.DofFar or 3.0))
            SetCamDofStrength(scene.cam, camCfg.DofStrength or 0.9)
        end

        SetCamActiveWithInterp(scene.cam, scene.camStart, Scene_InterpIn(), 1, 1)

        scene.animLoaded = Scene_LoadAnimation(cfg.Dict)
        if scene.animLoaded then Scene_PlayTabletAnimation(ped) end

        local propDelay = cfg.PropDelay or 450
        Wait(propDelay)
        if TabletScene.token ~= token then return end

        if not scene.noProp then Scene_AttachTabletProp(ped) end

        Wait(math.max(0, Scene_InterpIn() * 0.55 - propDelay))
        if TabletScene.token ~= token then return end
        if onReady and not TabletScene.wantClose then onReady() end

        Wait(math.max(0, Scene_InterpIn() * 0.45))
        if TabletScene.token ~= token then return end

        TabletScene.state = 'open'

        if TabletScene.wantClose then
            TabletScene.Stop()
            return
        end

        local startedAt = GetGameTimer()

        while TabletScene.state == 'open' and TabletScene.token == token do
            Wait(0)

            local current = PlayerPedId()
            if current ~= ped or IsEntityDead(current)
                or IsPedRagdoll(current) or IsPedInAnyVehicle(current, false) then
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'forceClose' })
                TabletScene.Stop(true)
                break
            end

            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 37, true)

            if not scene.noProp then
                if scene.animLoaded and not IsEntityPlayingAnim(ped, cfg.Dict, cfg.Anim, 3) then
                    Scene_PlayTabletAnimation(ped)
                end

                if not scene.prop or not DoesEntityExist(scene.prop) then
                    Scene_AttachTabletProp(ped)
                end
            end

            if camCfg.Sway and scene.cam then
                local elapsed = (GetGameTimer() - startedAt) / 1000.0
                local sx = math.sin(elapsed * 0.45) * camCfg.Sway
                local sz = math.sin(elapsed * 0.7) * camCfg.Sway * 0.6

                SetCamCoord(
                    scene.cam,
                    camPos.x + right.x * sx,
                    camPos.y + right.y * sx,
                    camPos.z + sz
                )
            end
        end
    end)

    return true
end