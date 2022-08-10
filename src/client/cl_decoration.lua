isDecorating = false
currentFocusEntity = nil
currentCamera = nil

local function StartDisableControlLoop()
    return CreateThread(function()
        repeat 
            Wait(5)
            print('Disabling controls')
        until not isDecorating
    end)
end

local function StartCameraLoop()
    return CreateThread(function()
        repeat 
            Wait(10)
            if (currentCamera) then
                CameraLookAtEntity(currentCamera, currentFocusEntity, vec3(2.0, 0.0, 1.0))
            end
        until not isDecorating
    end)
end

local function SetupPlayer()
    local player = PlayerPedId()

    -- make the player invisible
    SetEntityVisible(player, false)
    StartDisableControlLoop()
    SetEntityVisible(player, true)
end

local function CameraLookAtEntity(camera, entity, offset)
    local entityCoords = GetEntityCoords(entity)
    local camRotation = GetEntityRotation(camera)

    local forwardVector, rightVector, _, position = GetEntityMatrix(camera)
    local newPosition = (forwardVector * offset) + position

    SetEntityCoords(camera, newPosition.x, newPosition.y, entityCoords.z)
    SetEntityRotation(camera, camRotation.x, camRotation.y, camRotation.z, 2, true)
end

local function InitCamera()
    local camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)
    SetCamFov(camera, 90.0)
    SetCamRot(camera, 0.0, 0.0, 0.0)

    return camera
end

local function InitObject()
    local objectHash = GetHashKey(props["Interior"][1])
    object = CreateObject(objectHash, GetEntityCoords(PlayerPedId()), false, true, true)
    return object
end

function StartDecorating()
    if (propertyPlayerIsIn and propertyPlayerIsIn.shell.disable_decorate) then
        -- this property can't be decorated
        return
    end
    
    isDecorating = true
    SetupPlayer()

    currentFocusEntity = InitObject()
    currentCamera = InitCamera()

    StartCameraLoop()

    -- create a local object in the room
    -- create a new scriptable camera
    -- attach the camera to the object
    -- make control for the player to move the camera and place the object
end

AddEventHandler('bnl-housing:client:decorate', StartDecorating)

function FocusEntity(entity)
    -- set the focus to the entity
end