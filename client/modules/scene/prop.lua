function Scene_AttachTabletProp(ped)
    local cfg = Config.Scene
    local hash = Scene_LoadModel(cfg.Prop)
    if not hash then return false end

    local coords = GetEntityCoords(ped)
    local prop = CreateObject(hash, coords.x, coords.y, coords.z + 0.2, false, false, false)
    SetModelAsNoLongerNeeded(hash)

    if not DoesEntityExist(prop) then return false end

    SetEntityCollision(prop, false, false)
    AttachEntityToEntity(
        prop,
        ped,
        GetPedBoneIndex(ped, cfg.Bone),
        cfg.Offset.x, cfg.Offset.y, cfg.Offset.z,
        cfg.Rotation.x, cfg.Rotation.y, cfg.Rotation.z,
        true, true, false, true, 1, true
    )

    SceneRuntime.prop = prop
    return true
end

function Scene_DeleteTabletProp()
    local prop = SceneRuntime.prop
    if prop and DoesEntityExist(prop) then
        DetachEntity(prop, true, true)
        DeleteEntity(prop)
    end
    SceneRuntime.prop = nil
end

function TabletScene.DropProp()
    SceneRuntime.noProp = true
    Scene_DeleteTabletProp()

    local ped = SceneRuntime.ped
    local cfg = Config.Scene

    if ped and DoesEntityExist(ped)
        and IsEntityPlayingAnim(ped, cfg.Dict, cfg.Anim, 3) then
        StopAnimTask(ped, cfg.Dict, cfg.Anim, 2.5)
    end
end