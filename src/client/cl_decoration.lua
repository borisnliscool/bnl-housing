isDecorating = false
currentFocusEntity = nil
currentCamera = nil

local disabledKeys = {
    0, 1, 2, 3, 4, 5, 6, 7, 8,
    14, 15, 16, 17
}

local function StartDisableControlLoop()
    return CreateThread(function()
        repeat 
            Wait(5)

            for _,v in pairs(disabledKeys) do
                DisableControlAction(0, v-1, isDecorating)
            end
        until not isDecorating

        -- Reset the disabled keys
        for _,v in pairs(disabledKeys) do
            DisableControlAction(0, v-1, isDecorating)
        end
    end)
end

local function InitCamera(coord)
    local camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)
    SetCamRot(camera, 0.0, 0.0, 0.0)
    SetCamCoord(camera, coord)

    return camera
end

local function GetLocationForCameraRotation(rotation, location, offset)
    local aplha = math.rad(rotation.z - 90)
    local x = location.x + (math.cos(aplha) * offset)
    local y = location.y + (math.sin(aplha) * offset)

    local beta = math.rad(rotation.x - 90)
    local z = location.z - (math.cos(beta) * offset)

    return vec3(x, y, z)
end

local function CanRotateCam()
    return not IsPauseMenuActive()
end

local function StartCameraLoop()
    return CreateThread(function()
        local currentDistance = 2.5
        local minDistance = 0.5
        local maxDistance = 5.0
        repeat 
            Wait(10)
            if (currentCamera) then
                local horizontal = 0
                local vertical = 0
                local sensitivity = 5

                if (not CanRotateCam()) then goto continue end

                -- Rotation Calculation
                if (GetDisabledControlNormal(0, 1) ~= 0) then
                    horizontal = GetDisabledControlNormal(0, 1) * -sensitivity
                end
                if (GetDisabledControlNormal(0, 2) ~= 0) then
                    vertical = GetDisabledControlNormal(0, 2) * -sensitivity
                end

                -- Distance Calculation
                if (GetDisabledControlNormal(0, 14) ~= 0) then
                    currentDistance = currentDistance + (GetDisabledControlNormal(0, 14) * 0.5)
                end
                if (GetDisabledControlNormal(0, 15) ~= 0) then
                    currentDistance = currentDistance - (GetDisabledControlNormal(0, 15) * 0.5)
                end
                currentDistance = math.min(maxDistance, math.max(minDistance, currentDistance))

                local currentRotation = GetCamRot(currentCamera, 2)
                local newRotation = currentRotation + vec3(vertical, 0, horizontal)
                newRotation = vec3(math.min(85, math.max(-85, newRotation.x)), newRotation.y, newRotation.z)

                local newLocation = GetLocationForCameraRotation(newRotation, GetEntityCoords(currentFocusEntity) + vec3(0,0,1), currentDistance)
                SetCamCoord(currentCamera, newLocation)
                SetCamRot(currentCamera, newRotation.x, 0.0, newRotation.z, 2, true)
                
                ::continue::
            end

        until not isDecorating

        DisplayRadar(true)
    end)
end

local function SetupPlayer()
    local player = PlayerPedId()

    SetEntityVisible(player, false)
    StartDisableControlLoop()
    DisplayRadar(false)
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
    currentCamera = InitCamera(GetEntityCoords(PlayerPedId()))

    StartCameraLoop()
end

AddEventHandler('bnl-housing:client:decorate', StartDecorating)

function FocusEntity(entity)
    -- set the focus to the entity
    currentFocusEntity = entity
end