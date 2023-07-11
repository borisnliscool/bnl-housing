---@type number, number, string, vector3
local camera, entity, model, coords
local props = {}
local showBoundingBox, showOutline, showTransparancy = false, false, false

--#region Callbacks
RegisterNUICallback("close", function(data, cb)
    cb({})
    HideUI()
end)

RegisterNUICallback("navigate", function(page, cb)
    cb({})
    ShowUI(page)
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
--#endregion

---@param page string
function ShowUI(page)
    SendNUIMessage({
        action = "setVisible",
        data = true
    })
    SendNUIMessage({
        action = "setPage",
        data = page
    })
    SetNuiFocus(true, true)
    TriggerEvent("bnl-housing:on:showUI", page)
end

function HideUI()
    SendNUIMessage({
        action = "setVisible",
        data = false
    })
    SetNuiFocus(true, true)
    TriggerEvent("bnl-housing:on:hideUI")
end

---@param _entity number
---@param _coords vector3 | nil
function StartEditorWithEntity(_entity, _coords)
    if not _coords then
        _coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    end

    coords = _coords
    SetEntityCollision(_entity, false, false)

    -- Creating the camera
    local _camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(_camera, _coords.x + 1, _coords.y + 1, _coords.z + 1)
    SetCamFov(_camera, 70.0)
    PointCamAtCoord(_camera, _coords.x, _coords.y, _coords.z)
    RenderScriptCams(true, false, 0, true, false)

    SendNUIMessage({
        action = "setup",
        data = {
            entity = _entity,
            position = _coords,
            rotation = GetEntityRotation(_entity)
        }
    })

    ShowUI("decoration")
    TriggerEvent("bnl-housing:on:enterEditor")

    entity = _entity
    camera = _camera

    setTransparency()
    setOutline()
    setBoundingBox()
end

---@param _model string
function StartEditorWithModel(_model)
    model = _model

    -- Creating the entity
    lib.requestModel(_model)

    local hash = joaat(_model)
    lib.requestModel(hash, 5000)

    local _coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.0, 0.0)
    local _entity = CreateObject(hash, _coords.x, _coords.y, _coords.z, false, true, false)

    return StartEditorWithEntity(_entity, _coords)
end

---@param save boolean
---@return table | nil
function ExitEditor(save)
    local _ret
    RenderScriptCams(false, false, 0, true, false)

    if save then
        _ret = lib.callback.await("bnl-housing:server:property:decoration:addProp", false, CurrentProperty.id, {
            model = model,
            location = GetEntityCoords(entity),
            rotation = GetEntityRotation(entity)
        })
    end

    DeleteEntity(entity)
    TriggerEvent("bnl-housing:on:leaveEditor")

    camera, entity, model = 0, 0, ""
    return _ret
end

RegisterNUICallback("selectProp", function(_model, cb)
    cb({})
    StartEditorWithModel(_model)
end)

RegisterNUICallback("cancelPlacement", function(_, cb)
    cb({})
    ExitEditor(false)
    ShowUI("propPicker")
end)

RegisterNUICallback("savePlacement", function(_, cb)
    cb({})
    ExitEditor(true)
    ShowUI("propPicker")
end)

RegisterNUICallback("getProps", function(category, cb)
    cb(table.map(Data.Props[category], function(name)
        return {
            name = name,
            category = category,
        }
    end))
end)

--#region temp
RegisterCommand("housing:test", function(source, args, rawCommand)
    StartEditorWithModel(args[1] or "prop_bench_01a")
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

RegisterCommand("housing:menu", ShowPropPicker, false)
--#endregion
