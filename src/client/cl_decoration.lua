isDecorating = false
currentFocusEntity = nil
currentCamera = nil
isMenuOpen = false

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

local function GetLocationForCameraRotation(rotation, location, offset)
    local aplha = math.rad(rotation.z - 90)
    local x = location.x + (math.cos(aplha) * offset)
    local y = location.y + (math.sin(aplha) * offset)

    local beta = math.rad(rotation.x - 90)
    local z = location.z - (math.cos(beta) * offset)

    return vec3(x, y, z)
end

local function InitCamera(coord)
    local camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)
    SetCamRot(camera, 0.0, 0.0, 0.0)
    SetCamCoord(camera, GetLocationForCameraRotation(vec3(0,0,0), coord + vec3(0,0,1), 2.5))

    return camera
end

local function CanRotateCam()
    return
            not IsPauseMenuActive()
        and not isMenuOpen
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

                local newLocation = GetLocationForCameraRotation(newRotation, GetEntityCoords(currentFocusEntity), currentDistance)
                SetCamCoord(currentCamera, newLocation)
                SetCamRot(currentCamera, newRotation.x, 0.0, newRotation.z, 2, true)
                
                ::continue::
            end

        until not isDecorating

        DisplayRadar(true)
    end)
end

local function SetupPlayer()
    StartDisableControlLoop()
    
    SetEntityVisible(cache.ped, false)
    DisplayRadar(false)
end

local function InitObject(prop, coords)
    object = CreateObjectNoOffset(prop, coords, false, false, false)
    FreezeEntityPosition(object, true)
    SetEntityCollision(object, false, false)
    return object
end

local function GetPropCategory()
    local Promise = promise.new()

    local categories = {}
    for k,v in pairs(props) do
        table.insert(categories, k)
    end
    table.sort(categories, function(a, b) return a < b end)

    lib.registerMenu({
        id = 'decoration_category',
        title = 'Choose a category',
        onClose = function()
            Promise:resolve('')
        end,
        options = {
            { label = 'Category', values = categories },
        }
    }, function(selected, scrollIndex, args)
        Promise:resolve(categories[scrollIndex])
    end)
    lib.showMenu('decoration_category')

    local result = Citizen.Await(Promise)
    return result
end

local function AddPropMenu()
    local category = props[GetPropCategory()]
    if (not category) then return end

    local coord = GetEntityCoords(cache.ped)
    currentFocusEntity = InitObject(category[1], coord)

    local propsList = {}
    for k,v in pairs(category) do
        table.insert(propsList, v)
    end
    table.sort(propsList, function(a, b) return a < b end)

    isDecorating = true
    isMenuOpen = true
    SetupPlayer()

    lib.registerMenu({
        id = 'decoration_prop',
        title = 'Prop Menu',
        onSideScroll = function(selected, scrollIndex, args)
            if (currentFocusEntity) then DeleteEntity(currentFocusEntity) end
            currentFocusEntity = InitObject(propsList[scrollIndex], coord)
        end,
        onClose = function()
            isMenuOpen = false
            print('close')
            if (currentFocusEntity) then DeleteEntity(currentFocusEntity) end
        end,
        options = {
            { label = 'Prop', values = propsList },
            { label = 'Change Location', icon = 'location-crosshairs' },
        }
    }, function(selected, scrollIndex, args)
        isMenuOpen = false
        print('selected', selected, scrollIndex, args)
    end)
    lib.showMenu('decoration_prop')

    currentCamera = InitCamera(coord)
    StartCameraLoop()
end

local function OpenMainMenu()
    isMenuOpen = true

    lib.registerMenu({
        id = 'decorating_menu',
        title = locale('decoration_menu'),
        onClose = function()
            isMenuOpen = false
        end,
        options = {
            { label = 'Create a prop', icon = 'plus' },
            { label = 'Edit a prop', icon = 'edit' },
            { label = 'Remove a prop', icon = 'remove' },
        }
    }, function(selected, scrollIndex, args)
        if (selected == 1) then
            -- Add prop menu
            AddPropMenu()
        elseif (selected == 2) then
            -- Edit prop menu
        elseif (selected == 3) then
            -- Remove prop menu
        end
    end)
    lib.showMenu('decorating_menu')
end

function StartDecorating()
    if (propertyPlayerIsIn and propertyPlayerIsIn.shell.disable_decorate) then
        -- this property can't be decorated
        return
    end
    
    OpenMainMenu()
end

AddEventHandler('bnl-housing:client:decorate', StartDecorating)

function FocusEntity(entity)
    -- set the focus to the entity
    currentFocusEntity = entity
end