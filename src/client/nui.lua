local camera, entity, model
local props = {}

RegisterNUICallback("update", function(data, cb)
    local propCoords = vec(data.prop.position.z, data.prop.position.x, data.prop.position.y) + cache.coords

    ---@diagnostic disable-next-line: missing-parameter
    SetEntityCoords(entity, propCoords.x, propCoords.y, propCoords.z)
    ---@diagnostic disable-next-line: missing-parameter
    SetEntityRotation(entity, data.prop.rotation.x, data.prop.rotation.y, data.prop.rotation.z)

    if data.camera then
        local camCoords = vec(data.camera.position.z, data.camera.position.x, data.camera.position.y) + cache.coords
        SetCamCoord(camera, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(camera, propCoords.x, propCoords.y, propCoords.z)
    end

    cb({})
end)

local function ExitUI(save)
    RenderScriptCams(false, true, 500, true, false)

    if save then
        SetEntityCollision(entity, true, true)
        FreezeEntityPosition(entity, true)

        table.insert(props, {
            model = model,
            coords = GetEntityCoords(entity),
            rotation = GetEntityRotation(entity)
        })
    else
        DeleteEntity(entity)
    end

    SendNUIMessage({
        action = 'setVisible',
        data = false
    })
    SetNuiFocus(false, false)

    camera, entity, model = nil, nil, nil
end

RegisterNUICallback("cancelPlacement", function(data, cb)
    cb({})
    ExitUI(false)
end)

RegisterNUICallback("savePlacement", function(data, cb)
    cb({})
    ExitUI(true)
end)

RegisterCommand("housing:test", function(source, args, rawCommand)
    -- Creating the entity
    model = args[1] or "prop_bench_01a"
    lib.requestModel(model)

    local hash = joaat(model)
    lib.requestModel(hash, 5000)

    local coords = cache.coords
    entity = CreateObject(hash, coords.x, coords.y, coords.z, false, true, false)
    SetEntityCollision(entity, false, false)

    -- Creating the camera
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(camera, coords.x + 1, coords.y + 1, coords.z + 1)
    SetCamFov(camera, 70.0)
    PointCamAtCoord(camera, coords.x, coords.y, coords.z)
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
        action = "setVisible",
        data = true
    })
    SendNUIMessage({
        action = "setPage",
        data = "decoration"
    })
    SetNuiFocus(true, true)
end, false)

RegisterCommand("housing:exit", function(source, args, rawCommand)
    ExitUI()
end, false)

RegisterCommand("housing:print", function(source, args, rawCommand)
    Debug.Log(props)
    lib.setClipboard(json.encode(props))
end, false)
