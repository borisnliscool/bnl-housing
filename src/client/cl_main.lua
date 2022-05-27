allPropertyLocations = nil; allPropertyPoints = nil; shellObject = nil; isInProperty = false; propertyPlayerIsIn = nil; currentPropertyPermissionLevel = nil; inPropertyPoints = nil; currentPropertyProps = nil; decorationPoints = nil; specialProps = nil;

Citizen.CreateThread(function()
    allPropertyLocations = lib.callback.await('bnl-housing:server:getAllPropertyLocations', 1500)
    RegisterAllPropertyPoints()
    specialProps = data('specialprops')
end)

RegisterNetEvent("bnl-housing:client:notify", function(data)
    lib.defaultNotify(data)
end)

function RegisterAllPropertyPoints()
    Logger.Log('Registering all property points')

    if allPropertyPoints ~= nil then
        for _,point in pairs(allPropertyPoints) do
            point:remove()
        end
    end

    if allPropertyLocations ~= nil then
        for _,property in pairs(allPropertyLocations) do
            local entranceV3 = vector3(property.entrance.x, property.entrance.y, property.entrance.z)
            Logger.Log('Registering property point for property #' .. property.property_id .. ' at ' .. tostring(entranceV3))

            local point = lib.points.new(entranceV3, 10, {
                property_id = property.property_id,
            })

            local entered = false
            function point:nearby()
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.25, 0.25, 0.25, 0, 150, 255, 155, false, true, 2, nil, nil, false)

                if self.currentDistance < 1.5 then
                    if not entered then
                        lib.showTextUI(locale('open_property_menu'))
                        entered = true
                    end

                    if IsControlJustReleased(0, 38) then
                        OpenPropertyEnterMenu(self.property_id)
                    end
                else
                    if entered then
                        lib.hideTextUI()
                        entered = false
                    end
                end
            end
        end
    end
end

function SpawnPropertyDecoration(property)
    DespawnPropertyDecoration()

    local decoration = json.decode(property.decoration)
    local shellCoord = GetEntityCoords(shellObject)

    if currentPropertyProps == nil then
        currentPropertyProps = {}
    end

    for _,prop in pairs(decoration) do
        local propCoord = shellCoord - vector3(prop.x, prop.y, prop.z)
        local propModel = prop.model

        local propObject = CreateObject(GetHashKey(propModel), propCoord.x, propCoord.y, propCoord.z, true, true, true)
        SetEntityHeading(propObject, prop.w)
        FreezeEntityPosition(propObject, true)
        SetEntityAsMissionEntity(propObject, true, true)
        table.insert(currentPropertyProps, propObject)

        for spName, spData in pairs(specialProps) do
            if (spName == propModel) then
                local point = lib.points.new(propCoord, spData.range, {
                    property_id = property.property_id,
                    spData = spData,
                    entity = propObject,
                })

                function point:onEnter()
                    if (spData.closeText) then
                        lib.showTextUI(spData.closeText)
                    end
                    if (spData.outline) then
                        SetEntityDrawOutline(self.entity, true)
                        if (spData.outline.color) then
                            SetEntityDrawOutlineColor(self.entity, spData.outline.color[1], spData.outline.color[2], spData.outline.color[3], spData.outline.color[4])
                        end
                        if (spData.outline.shader) then
                            SetEntityDrawOutlineShader(spData.outline.shader)
                        end
                    end
                end
                
                function point:onExit()
                    if (spData.closeText) then
                        lib.hideTextUI()
                    end
                    if (spData.outline) then
                        SetEntityDrawOutline(self.entity, false)
                    end
                end

                function point:nearby()
                    if (IsControlJustPressed(0, 38)) then
                        if (spData.func ~= nil) then
                            spData.func(prop)
                        end
                    end
                    if (spData.marker) then
                        local md = spData.marker
                        local coords = self.coords + md.offset
                        DrawMarker(md.sprite, coords, 0.0, 0.0, 0.0, md.rotation, md.scale, md.color[1], md.color[2], md.color[3], md.color[4], md.bob, md.faceCamera, 2, nil, nil, false)
                    end
                end

                if (decorationPoints == nil) then
                    decorationPoints = {}
                end

                table.insert(decorationPoints, point)
            end
        end
    end
end

function DespawnPropertyDecoration()
    if currentPropertyProps ~= nil then
        for _,prop in pairs(currentPropertyProps) do
            DeleteEntity(prop)
        end
        currentPropertyProps = nil
    end

    if decorationPoints ~= nil then
        for _,point in pairs(decorationPoints) do
            point:remove()
        end
        decorationPoints = nil
    end
end

function SpawnPropertyShell(property, shell)
    Logger.Log(string.format('Spawning shell #%s for property #%s', shell.id, property.id))

    if shellObject ~= nil or shellObject ~= 0 then
        DeleteEntity(shellObject)
    end

    entrance = json.decode(property.entrance)
    local shellSpawnLocation = vector3(entrance.x, entrance.y, entrance.z) - lowerBy
    local shellModel = GetHashKey(shell.spawn)
    shellObject = CreateObject(shellModel, shellSpawnLocation, false, false, false)
    FreezeEntityPosition(shellObject, true)
    SetEntityAsMissionEntity(shellObject, true, true)

    return shellObject
end

function HandlePropertyMenus(property)
    if inPropertyPoints ~= nil then
        for _,point in pairs(inPropertyPoints) do
            point:remove()
        end
    end
    inPropertyPoints = {}

    local shellCoord = GetEntityCoords(shellObject)
    local property_id = property.id
    
    local foot_entrance = shellCoord - V4ToV3(property.shell.foot_entrance)
    local foot_point = lib.points.new(foot_entrance, 5, {
        property_id = property.id,
        type = 'foot',
    })

    local foot_entered = true
    function foot_point:nearby()
        if (not IsPedInAnyVehicle(cache.ped, true)) then
            if self.currentDistance < 1 then
                if not foot_entered then
                    lib.registerContext({
                        id = 'property_manage_keys',
                        title = locale('manage_keys'),
                        menu = 'property_foot',
                        options = {
                            {
                                title = locale('take_keys'),
                                event = 'bnl-housing:client:takeKeysMenu',
                                arrow = true,
                            },
                            {
                                title = locale('give_keys'),
                                event = 'bnl-housing:client:giveKeysMenu',
                                arrow = true,
                            },
                        }
                    })

                    local foot_options = {
                        {
                            title = locale('exit_property'),
                            event = 'bnl-housing:client:exit',
                        },
                    }
                    if (currentPropertyPermissionLevel == "key_owner" or currentPropertyPermissionLevel == "owner") then
                        table.insert(foot_options, {
                            title = locale('invite_to_property'),
                            event = 'bnl-housing:client:invite',
                            arrow = true,
                            args = {
                                property_id = property_id,
                            },
                        })
                        table.insert(foot_options, {
                            title = locale('decorate_property'),
                            event = 'bnl-housing:client:decorate',
                            arrow = true,
                            args = {
                                property_id = property_id,
                            },
                        })
                    end
                    if (currentPropertyPermissionLevel == "owner") then
                        table.insert(foot_options, {
                            title = locale('manage_keys'),
                            menu = 'property_manage_keys',
                            arrow = true,
                        })
                        table.insert(foot_options, {
                            title = locale('sell_property'),
                            event = 'bnl-housing:client:sell',
                        })
                        table.insert(foot_options, {
                            title = locale('rent_property'),
                            event = 'bnl-housing:client:rent',
                        })
                        -- TODO: MAKE THIS WORK WITH DIFFERENT LOCK STATES, MAYBE EVEN RERMOVE IT
                        -- table.insert(foot_options, {
                        --     title = locale('unlock_property'),
                        --     event = 'bnl-housing:client:propertyOption',
                        --     args = {
                        --         property_id = property_id,
                        --         type = 'unlock',
                        --     },
                        -- })
                    end
                    lib.registerContext({
                        id = 'property_foot',
                        title = locale('property_menu'),
                        options = foot_options
                    })
                    lib.showContext('property_foot')
                    foot_entered = true
                end
            else
                if foot_entered then
                    foot_entered = false
                end
            end
        end
    end

    table.insert(inPropertyPoints, foot_point)

    local vehicle_entrance = shellCoord - V4ToV3(property.shell.vehicle_entrance)
    local vehicle_point = lib.points.new(vehicle_entrance, 5, {
        property_id = property.id,
        type = 'vehicle',
    })

    local vehicle_entered = true
    function vehicle_point:nearby()
        if (IsPedInAnyVehicle(cache.ped, true)) then
            DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.25, 0.25, 0.25, 0, 150, 255, 155, false, true, 2, nil, nil, false)

            if self.currentDistance < 1.5 then
                if not entered then
                    lib.showTextUI(locale('open_menu'))
                    entered = true
                end

                if IsControlJustReleased(0, 38) then
                    lib.registerContext({
                        id = 'property_vehicle',
                        title = locale('property_menu'),
                        options = {
                            {
                                title = locale('exit_property'),
                                event = 'bnl-housing:client:exit',
                            },
                        }
                    })
                    lib.showContext('property_vehicle')
                end
            else
                if entered then
                    lib.hideTextUI()
                    entered = false
                end
            end
        end
    end
end

function HandleEnter(data)
    lib.hideTextUI()

    DoScreenFadeOut(500)
    Wait(500)

    local property = data.property
    propertyPlayerIsIn = property
    currentPropertyPermissionLevel = data.permissionLevel
    isInProperty = true

    local shell = property.shell
    SpawnPropertyShell(property, shell)
    SpawnPropertyDecoration(property)
    HandlePropertyMenus(property)

    if data.withVehicle and IsPedInAnyVehicle(cache.ped, false) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        SetEntityCoords(vehicle, GetEntityCoords(shellObject) - V4ToV3(shell.vehicle_entrance) - vector3(0,0,1.0))
        SetEntityHeading(vehicle, GetEntityHeading(shellObject) + shell.vehicle_entrance.w)
    else
        SetEntityCoords(cache.ped, GetEntityCoords(shellObject) - V4ToV3(shell.foot_entrance) - vector3(0,0,1.0))
        SetEntityHeading(cache.ped, GetEntityHeading(shellObject) + shell.foot_entrance.w)
    end

    DoScreenFadeIn(500)
end

RegisterNetEvent("bnl-housing:client:setVehicleProps", function(networkId, props)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    if (not DoesEntityExist(vehicle)) then
        return
    end
    SetVehicleProperties(vehicle, props)
end)

RegisterNetEvent("bnl-housing:client:enter", function(menuData)
    local vehicleEnter = false
    if (IsPedInAnyVehicle(cache.ped, false)) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        if (IsPedVehicleDriver(cache.ped, vehicle)) then
            vehicleEnter = true
        else
            lib.defaultNotify({
                title = locale('property'),
                description = locale('not_driver'),
                status = 'error',
            })
            return
        end
    end
    local data = lib.callback.await('bnl-housing:server:enter', false, menuData.property_id, vehicleEnter)
    
    if (data.ret == true) then
        HandleEnter(data)
    else
        if (data.notification) then
            lib.defaultNotify(data.notification)
        end
    end
end)

RegisterNetEvent("bnl-housing:client:knock", function(data)
    local property_id = data.property_id
    local data = lib.callback.await('bnl-housing:server:knock', false, property_id)

    lib.defaultNotify(data.notification)
end)

RegisterNetEvent("bnl-housing:client:knocking", function()
    HelpNotification(locale('knocking_on_door'), 10000)
    local property = propertyPlayerIsIn
    local shellCoord = GetEntityCoords(shellObject)
    local property_id = property.id
    local foot_entrance = shellCoord - V4ToV3(property.shell.foot_entrance)
    Play3DSound('knocking', #(V4ToV3(foot_entrance) - GetEntityCoords(cache.ped)))
end)

RegisterNetEvent("bnl-housing:client:breakin", function(data)
    local property_id = data.property_id
    local data = lib.callback.await('bnl-housing:server:breakin', false, property_id)

    lib.defaultNotify(data.notification)
end)

function OpenPropertyEnterMenu(property_id)
    local options = {
        {
            title = locale('enter_property'),
            event = 'bnl-housing:client:enter',
            args = {
                property_id = property_id,
            },
        },
    }

    if (not IsPedInAnyVehicle(cache.ped)) then
        table.insert(options, {
            title = locale('knock_on_door'),
            event = 'bnl-housing:client:knock',
            args = {
                property_id = property_id
            },
        })
        table.insert(options, {
            title = locale('break_in'),
            event = 'bnl-housing:client:breakin',
            args = {
                property_id = property_id,
                type = 'lockpick',
            },
        })
    end

    lib.registerContext({
        id = 'property_enter',
        title = locale('property_menu'),
        options = options
    })
    lib.showContext('property_enter')
end

RegisterNetEvent("bnl-housing:client:updatePropertyLocations", function(locations)
    allPropertyLocations = locations
    RegisterAllPropertyPoints()
end)

RegisterNetEvent("bnl-housing:client:takeKeys", function(data)
    TriggerServerEvent("bnl-housing:server:takeKeys", data.player_id)
end)

RegisterNetEvent("bnl-housing:client:takeKeysMenu", function()
    local data = lib.callback.await('bnl-housing:server:take_keys_menu', false)
    
    if (data.ret) then
        local options = {}
        for _,player in pairs(data.keys) do
            table.insert(options, {
                title = player.name,
                event = 'bnl-housing:client:takeKeys',
                args = {
                    player_id = player.identifier,
                },
            })
        end

        lib.registerContext({
            id = 'take_keys',
            title = locale('take_keys'),
            menu = 'property_foot',
            options = options,
        })
        lib.showContext('take_keys')
    else
        lib.defaultNotify(data.notification)
    end
end)

RegisterNetEvent("bnl-housing:client:giveKeys", function(data)
    TriggerServerEvent("bnl-housing:server:giveKeys", data.player_id)
end)

RegisterNetEvent("bnl-housing:client:giveKeysMenu", function()
    local players = lib.callback.await('bnl-player:server:getPlayersAtCoord', false, GetEntityCoords(cache.ped), 2.5, false)
    local options = {}

    for _,player in pairs(players) do
        table.insert(options, {
            title = player.name,
            event = 'bnl-housing:client:giveKeys',
            args = {
                player_id = player.id,
            },
        })
    end

    if (#options == 0) then
        lib.defaultNotify({
            title = locale('property'),
            description = locale('keys_noone_close'),
            status = 'error',
        })
    else
        lib.registerContext({
            id = 'give_keys',
            title = locale('give_keys'),
            menu = 'property_foot',
            options = options,
        })
        lib.showContext('give_keys')
    end
end)

RegisterNetEvent("bnl-housing:client:exit", function()
    local vehicleExit = false
    if (IsPedInAnyVehicle(cache.ped, false)) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        if (IsPedVehicleDriver(cache.ped, vehicle)) then
            vehicleExit = true
        else
            lib.defaultNotify({
                title = locale('property'),
                description = locale('not_driver'),
                status = 'error',
            })
            return
        end
    end

    local data = lib.callback.await('bnl-housing:server:exit', false, vehicleExit)
    if data.ret then
        Logger.Info(data)
        local vehicle = GetVehiclePedIsIn(cache.ped, false)

        if (data.deleteVehicle) then 
            DeleteVehicle(vehicle)
        end

        if (data.withVehicle) then
            SetEntityCoords(vehicle, JsonCoordToVector3(propertyPlayerIsIn.entrance) - vector3(0,0,1.0))
            SetEntityHeading(vehicle, json.decode(propertyPlayerIsIn.entrance).w)
        else
            SetEntityCoords(cache.ped, JsonCoordToVector3(propertyPlayerIsIn.entrance) - vector3(0,0,1.0))
            SetEntityHeading(cache.ped, json.decode(propertyPlayerIsIn.entrance).w)
        end

        lib.hideTextUI()
        isInProperty = false
        propertyPlayerIsIn = nil
        currentPropertyPermissionLevel = nil
        
        if shellObject ~= nil or shellObject ~= 0 then
            DeleteEntity(shellObject)
        end
        
        if currentPropertyProps ~= nil then
            for _,prop in pairs(currentPropertyProps) do
                DeleteEntity(prop)
            end
        
            currentPropertyProps = nil
        end
    end
end)

RegisterNetEvent("bnl-housing:client:getInvite", function()
    HelpNotification(locale('invited_to_property'), 30000)

    Citizen.CreateThread(function()
        count = 0
        repeat
            Wait(1)
            count = count + 1
            if IsControlJustReleased(0, 47) then
                local data = lib.callback.await('bnl-housing:server:acceptInvite', false)
                if (data.ret) then
                    HandleEnter(data)
                end
                break
            end
        until count > 30000 or isInProperty
        HelpNotification(locale('entered_property'), 2500)
    end)
end)

RegisterNetEvent("bnl-housing:client:invitePlayer", function(data)
    TriggerServerEvent("bnl-housing:server:invitePlayer", data.player)
end)

RegisterNetEvent("bnl-housing:client:invite", function()
    local players = lib.callback.await('bnl-player:server:getPlayersAtCoord', false, JsonCoordToVector3(propertyPlayerIsIn.entrance), 2.5)
    local options = {}
    for _,player in pairs(players) do
        table.insert(options, {
            title = player.name,
            event = 'bnl-housing:client:invitePlayer',
            args = {
                player = player.id,
                property_id = propertyPlayerIsIn.id,
            }
        })
    end

    if #options == 0 then
        lib.defaultNotify({
            title = locale('property'),
            description = locale('noone_outside'),
            status = 'error',
        })
    else
        lib.registerContext({
            id = 'invite',
            title = locale('invite_to_property'),
            menu = 'property_foot',
            options = options
        })
        lib.showContext('invite')
    end
end)

RegisterNetEvent("bnl-housing:client:sell", function()
    local confirmString = locale('sell_confirm_string')
    local data = lib.inputDialog(locale('sell_property'), {locale('sell_price'), locale('sell_confirm', confirmString)})

    if data then
        if data[2] ~= confirmString then
            lib.defaultNotify({
                title = locale('property'),
                description = locale('sell_confirm_error', confirmString),
                status = 'error',
            })
            return
        end

        local sellAmount = tonumber(data[1])
        lib.defaultNotify({
            title = locale('property'),
            description = "This feature is not yet implemented",
            status = 'error',
        })
    end
end)

RegisterNetEvent("bnl-housing:client:rent", function()
    lib.defaultNotify({
        title = locale('property'),
        description = "This feature is not yet implemented",
        status = 'error',
    })
end)

RegisterNetEvent("bnl-housing:client:requestVehicleData", function(vehicle)
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicle.networkId)
    if (vehicleEntity ~= nil) then
        local vehicleData = GetVehicleProperties(vehicleEntity)

        TriggerServerEvent("bnl-housing:server:postVehicleData", vehicle, vehicleData)
    end
end)

RegisterNetEvent("bnl-housing:client:setNetworkOwner", function(networkId)
    NetworkRequestControlOfNetworkId(networkId)
end)

RegisterNetEvent("bnl-housing:client:updateProperty", function(property)
    propertyPlayerIsIn = property
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if isInProperty then
            local property = propertyPlayerIsIn
            local entrance = JsonCoordToVector3(property.entrance)

            local vehicle = GetVehiclePedIsIn(cache.ped, false)
            if (vehicle and IsPedVehicleDriver(cache.ped, vehicle)) then
                SetEntityCoords(vehicle, entrance)
            else
                SetEntityCoords(cache.ped, entrance)
            end

            if (type(property.vehicles) == 'string') then property.vehicles = json.decode(property.vehicles) end
            for _,vehicle in pairs(property.vehicles) do
                local vehicleEntity = NetworkGetEntityFromNetworkId(vehicle.networkId)
                if (vehicleEntity ~= nil) then
                    if (not IsPedVehicleDriver(cache.ped, vehicleEntity)) then
                        DeleteEntity(vehicleEntity)
                    end
                end
            end
        end

        if allPropertyPoints ~= nil then
            for _,point in pairs(allPropertyPoints) do
                point:remove()
            end
        end

        if shellObject ~= nil or shellObject ~= 0 then
            DeleteEntity(shellObject)
        end

        if inPropertyPoints ~= nil then
            for _,point in pairs(inPropertyPoints) do
                point:remove()
            end
        end
    end
end)

-- TEMP
RegisterCommand("housing:getlocation", function(source, args, rawCommand)
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local location = vector4(coords.x, coords.y, coords.z, heading)
    lib.setClipboard(json.encode(location))
end)

RegisterCommand("housing:getRelativeCoord", function(source, args, rawCommand)
    local ped = cache.ped
    local pedcoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local shellcoords = GetEntityCoords(shellObject)
    lib.setClipboard(json.encode(vector4(vector3(shellcoords - pedcoords), heading)))
end)

RegisterCommand("housing:permission", function(source, args, rawCommand)
    Logger.Info(currentPropertyPermissionLevel)
end)

RegisterCommand("housing:current", function(source, args, rawCommand)
    Logger.Info(propertyPlayerIsIn)
end)
-- END