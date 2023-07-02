local camera
local entity

RegisterNUICallback("update", function(data, cb)
    cb()

    local propCoords = vec(data.prop.position.z, data.prop.position.x, data.prop.position.y) + cache.coords
    SetEntityCoords(entity, propCoords.x, propCoords.y, propCoords.z, false, false, false, false)
    SetEntityRotation(entity, data.prop.rotation.x, data.prop.rotation.y, data.prop.rotation.z, 2, false)

    if data.camera then
        local camCoords = vec(data.camera.position.z, data.camera.position.x, data.camera.position.y) + cache.coords
        SetCamCoord(camera, camCoords.x, camCoords.y, camCoords.z)
    end
end)

RegisterCommand("housing:test", function(source, args, rawCommand)
    -- Creating the entity
    local model = args[1] or "prop_bench_01a"
    lib.requestModel(model)

    local hash = joaat(model)
    lib.requestModel(hash, 5000)

    local coords = cache.coords
    entity = CreateObject(hash, coords.x, coords.y, coords.z, false, true, false)
    SetEntityCollision(entity, false, false)

    -- Creating the camera
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(camera, coords.x, coords.y, coords.z)
    PointCamAtEntity(camera, entity, 0, 0, 0, false)
    RenderScriptCams(true, true, 500, true, false)

    SendNUIMessage({
        action = "setup",
        data = {
            entity = entity,
            position = coords,
            rotation = GetEntityRotation(entity)
        }
    })
    SendNUIMessage({
        action = 'setVisible',
        data = true
    })
    SendNUIMessage({
        action = 'setPage',
        data = "decoration"
    })
    SetNuiFocus(true, true)
end, false)

RegisterCommand("housing:ui", function(source, args, rawCommand)
    SendNUIMessage({
        action = 'setVisible',
        data = true
    })
    SendNUIMessage({
        action = 'setPage',
        data = "decoration"
    })
    SetNuiFocus(true, true)
end, false)
