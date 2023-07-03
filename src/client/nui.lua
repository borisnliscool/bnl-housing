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

RegisterNUICallback("setOutline", function(outline, cb)
    SetEntityDrawOutline(entity, outline)
    cb({})
end)

RegisterNUICallback("setTransparent", function(transparent, cb)
    SetEntityAlpha(entity, transparent and 204 or 255, false)
    SetEntityDrawOutlineColor(0, 192, 255, 255)
    SetEntityDrawOutlineShader(1)
    cb({})
end)

---@param _model string
local function StartEditor(_model)
    model = _model

    -- Creating the entity
    lib.requestModel(model)

    local hash = joaat(model)
    lib.requestModel(hash, 5000)

    local coords = cache.coords
    local _entity = CreateObject(hash, coords.x, coords.y, coords.z, false, true, false)
    SetEntityCollision(_entity, false, false)

    -- Creating the camera
    local _camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(_camera, coords.x + 1, coords.y + 1, coords.z + 1)
    SetCamFov(_camera, 70.0)
    PointCamAtCoord(_camera, coords.x, coords.y, coords.z)
    RenderScriptCams(true, true, 500, true, false)

    -- todo:
    --  send entity bounds and handle that on the ui
    SendNUIMessage({
        action = "setup",
        data = {
            entity = _entity,
            position = coords,
            rotation = GetEntityRotation(_entity)
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

    entity = _entity
    camera = _camera
end

---@param save boolean
local function ExitEditor(save)
    RenderScriptCams(false, true, 500, true, false)

    if save then
        SetEntityCollision(entity, true, true)
        FreezeEntityPosition(entity, true)
        SetEntityDrawOutline(entity, false)
        ResetEntityAlpha(entity)

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

RegisterNUICallback("selectProp", function(model, cb)
    cb({})
    StartEditor(model)
end)

RegisterNUICallback("cancelPlacement", function(data, cb)
    cb({})
    ExitEditor(false)
end)

RegisterNUICallback("savePlacement", function(data, cb)
    cb({})
    ExitEditor(true)
end)

RegisterNUICallback("getProps", function(category, cb)
    cb(table.map(Data.Props[category], function(name)
        return {
            name = name,
            category = category,
        }
    end))
end)

RegisterCommand("housing:test", function(source, args, rawCommand)
    StartEditor(args[1] or "prop_bench_01a")
end, false)

RegisterCommand("housing:exit", function(source, args, rawCommand)
    ExitEditor(false)
end, false)

RegisterCommand("housing:print", function(source, args, rawCommand)
    local property = lib.callback.await("bnl-housing:server:property:inside", false)
    local currentPropertyLocation =
        property and lib.callback.await("bnl-housing:server:property:getLocation", false, property.id)

    local _props = table.map(props, function(prop)
        if not currentPropertyLocation then return prop end
        prop.coords = prop.coords - currentPropertyLocation
        return prop
    end)

    Debug.Log(_props)
    lib.setClipboard(json.encode(_props))
end, false)

RegisterCommand("housing:menu", function(source, args, rawCommand)
    SendNUIMessage({
        action = "setVisible",
        data = true
    })
    SendNUIMessage({
        action = "setPage",
        data = "propPicker"
    })
    SetNuiFocus(true, true)
end, false)
