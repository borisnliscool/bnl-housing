---@type number, number, string, vector3
local camera, entity, model, coords
local props = {}
local showBoundingBox, showOutline, showTransparancy = false, false, false

RegisterNUICallback("close", function(data, cb)
    cb({})
    SendNUIMessage({
        action = "setVisible",
        data = false
    })
    SetNuiFocus(false, false)
end)

RegisterNUICallback("navigate", function(page, cb)
    cb({})
    SendNUIMessage({
        action = "setPage",
        data = page
    })
end)

RegisterNUICallback("update", function(data, cb)
    local propCoords = vec(data.prop.position.z, data.prop.position.x, data.prop.position.y) + coords

    ---@diagnostic disable-next-line: missing-parameter
    SetEntityCoords(entity, propCoords.x, propCoords.y, propCoords.z)
    ---@diagnostic disable-next-line: missing-parameter
    SetEntityRotation(entity, data.prop.rotation.x, data.prop.rotation.y, data.prop.rotation.z)

    if data.camera then
        local camCoords = vec(data.camera.position.z, data.camera.position.x, data.camera.position.y) + coords
        SetCamCoord(camera, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(camera, propCoords.x, propCoords.y, propCoords.z)
    end

    cb({})
end)

local function setTransparency()
    SetEntityAlpha(entity, showTransparancy and 204 or 255, false)
end

local function setOutline()
    SetEntityDrawOutline(entity, showOutline)
    SetEntityDrawOutlineColor(0, 0, 200, 255)
    SetEntityDrawOutlineShader(1)
end

local function setBoundingBox()
    CreateThread(function()
        while showBoundingBox and entity ~= nil do
            Wait(0)
            DrawEntityBoundingBox(entity)
        end
    end)
end

RegisterNUICallback("setBoundingBox", function(show, cb)
    showBoundingBox = show
    setBoundingBox()
    cb({})
end)

RegisterNUICallback("setOutline", function(outline, cb)
    showOutline = outline
    setOutline()
    cb({})
end)

RegisterNUICallback("setTransparent", function(transparent, cb)
    showTransparancy = transparent
    setTransparency()
    cb({})
end)

---@param _model string
local function startEditor(_model)
    model = _model

    -- Creating the entity
    lib.requestModel(model)

    local hash = joaat(model)
    lib.requestModel(hash, 5000)

    coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    local _entity = CreateObject(hash, coords.x, coords.y, coords.z, false, true, false)
    SetEntityCollision(_entity, false, false)

    -- Creating the camera
    local _camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(_camera, coords.x + 1, coords.y + 1, coords.z + 1)
    SetCamFov(_camera, 70.0)
    PointCamAtCoord(_camera, coords.x, coords.y, coords.z)
    RenderScriptCams(true, false, 0, true, false)

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

    setTransparency()
    setOutline()
    setBoundingBox()
end

---@param save boolean
local function exitEditor(save)
    RenderScriptCams(false, false, 0, true, false)

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

    camera, entity, model = 0, 0, ""
end

RegisterNUICallback("selectProp", function(model, cb)
    cb({})
    startEditor(model)
end)

RegisterNUICallback("cancelPlacement", function(data, cb)
    cb({})
    exitEditor(false)

    SendNUIMessage({
        action = "setPage",
        data = "propPicker"
    })
end)

RegisterNUICallback("savePlacement", function(data, cb)
    cb({})
    exitEditor(true)

    SendNUIMessage({
        action = "setPage",
        data = "propPicker"
    })
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
    startEditor(args[1] or "prop_bench_01a")
end, false)

RegisterCommand("housing:exit", function(source, args, rawCommand)
    exitEditor(false)
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
