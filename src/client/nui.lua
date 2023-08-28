---@type number, number, string, vector3
local camera, entity, model, coords
local props = {}
local showBoundingBox, showOutline, showTransparancy = false, false, false
---@type "NONE" | "CREATING" | "EDITING"
local state = "NONE"
---@type number | nil
local currentPropId = nil

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

RegisterNUICallback("getPlacedProps", function(_, cb)
    local placedProps = FormatPlacedProps(CurrentProperty.props)
    cb(placedProps)
end)

---@param id number
local function DeleteProp(id)
    return lib.callback.await("bnl-housing:server:property:decoration:removeProp", false, CurrentProperty.id, id)
end

RegisterNUICallback("editProp", function(propId, cb)
    cb({})
    local prop = table.findOne(CurrentProperty.props, function(_prop)
        return _prop.id == propId
    end)
    if not prop then return end

    local entity = NetworkGetEntityFromNetworkId(
        lib.callback.await("bnl-housing:server:property:decoration:getPropEntity", false, CurrentProperty.id, prop.id)
    )
    if not entity then return end

    model = prop.model
    state = "EDITING"
    currentPropId = prop.id

    StartEditorWithEntity(entity, GetEntityCoords(entity))
end)

RegisterNUICallback("deleteProp", function(propId, cb)
    cb({})
    local prop = table.findOne(CurrentProperty.props, function(_prop)
        return _prop.id == propId
    end)
    if not prop then return end
    DeleteProp(prop.id)
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
    SetNuiFocus(false, false)
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
    state = "CREATING"
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

        if state == "EDITING" and currentPropId then
            DeleteProp(currentPropId)
        end
    end

    DeleteEntity(entity)
    TriggerEvent("bnl-housing:on:leaveEditor")

    camera, entity, model = 0, 0, ""
    state = "NONE"
    currentPropId = nil

    return _ret
end

local function payForProp(_model)
    local prop = GetPropFromModel(_model)
    if not prop then return end

    Debug.Log(Format("Paying $%s for a %s", prop.price, prop.name))
    lib.callback.await("bnl-housing:server:property:decoration:payForProp", false, CurrentProperty.id, _model)

    -- todo
    --  this isn't really a good way to do this as if the placement
    --  is canceled, the money is stil taken from the player
end

RegisterNUICallback("selectProp", function(_model, cb)
    cb({})
    StartEditorWithModel(_model)
    payForProp(_model)
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
    local data = table.map(Data.Props[category], function(prop)
        prop.category = category
        return prop
    end)
    cb(data)
end)
