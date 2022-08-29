allPropertyLocations, properties, shells, propertyTypes = nil, props;

lib.versionCheck('borisnliscool/bnl-housing')

CreateThread(function()
    shells = data('shells')
    propertyTypes = data('propertyTypes')
    props = data('props')

    MySQL.query('SELECT * FROM bnl_housing', function(result)
        if result then
            properties = {}

            allPropertyLocations = {}
            for _,property in pairs(result) do
                local property_id = property.id
                local entrance = json.decode(property.entrance)
                entrance = vector4(entrance.x, entrance.y, entrance.z, entrance.w)

                table.insert(allPropertyLocations, {
                    property_id = property_id,
                    entrance = entrance,
                })

                property.shell = nil
                property.saved_vehicles = json.decode(property.vehicles)
                property.vehicles = nil
                property.saved_players = json.decode(property.saved_players)

                for _,shell in pairs(shells) do
                    if (property.shell_id == shell.id) then
                        property.shell = shell
                        break
                    end
                end
                if (property.shell ~= nil) then
                    for propertyType, data in pairs(propertyTypes) do
                        if (property.shell.type == propertyType) then
                            property.type = data
                            break
                        end
                    end
                else
                    Logger.Error('Shell not found for property #' .. property_id)
                end

                properties[property_id] = property
            end
        end

        TriggerEvent('bnl-housing:event:onPropertiesLoaded', properties)
    end)
end)

lib.callback.register('bnl-housing:server:getAllPropertyLocations', function(source)
    return allPropertyLocations
end)

lib.callback.register('bnl-inventory:server:getAllShells', function(source)
    return shells
end)

lib.callback.register('bnl-player:server:getPlayersAtCoord', function(source, coord, radius, returnSelf)
    local players = {}
    for _,player in pairs(GetPlayers()) do
        if (not returnSelf and tonumber(player) == tonumber(source)) then goto continue end

        local player_coord = GetEntityCoords(GetPlayerPed(player))
        if #(player_coord - coord) <= radius then
            table.insert(players, {
                id = player,
                name = PlayerName(player),
            })
        end

        ::continue::
    end
    return players
end)

local propertyInvites = {}

lib.callback.register('bnl-housing:server:acceptInvite', function(source)
    for i=1,#propertyInvites do
        local invite = propertyInvites[i]
        if (invite.player == tostring(source)) then
            table.remove(propertyInvites, i)

            local property = GetPropertyById(invite.property_id)
            if (property) then
                local identifier = GetIdentifier(source)
                local permission = GetPlayerPropertyPermissionLevel(identifier, property)
                PlayerEnterProperty(property, {
                    name = PlayerName(source),
                    permissionLevel = permission,
                    identifier = identifier,
                    serverId = source,
                })

                TriggerEvent("bnl-housing:event:playerEnteredProperty", source, property)

                return {
                    ret = true,
                    property = property,
                    permissionLevel = permission,
                }
            end
        end
    end

    return {
        ret = false,
    }
end)

RegisterNetEvent("bnl-housing:server:invitePlayer", function(player)
    local property = GetPropertyPlayerIsInside(source)
    local plr = FindPlayerInProperty(property, source)

    if (not property or not plr) then return end

    if (plr.permissionLevel == "key_owner" or plr.permissionLevel == "owner") then
        for _,invite in pairs(propertyInvites) do
            if invite.player == player then
                goto eof
                return
            end
        end

        TriggerClientEvent("bnl-housing:client:getInvite", player)

        table.insert(propertyInvites, {
            source = source,
            player = player,
            property_id = property.id,
        })

        CreateThread(function()
            Wait(30000)

            for i=1,#propertyInvites do
                local invite = propertyInvites[i]
                if (tonumber(invite.player) == tonumber(player)) then
                    table.remove(propertyInvites, i)
                end
            end
        end)
    else
        Logger.Error(string.format("Player %s tried to invite player %s to property %s, but they don't have permission.", PlayerName(source), PlayerName(player), property.name))
    end
    ::eof::
end)

lib.callback.register('bnl-housing:server:enter', function(source, property_id, enterWithVehicle)
    local player = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(player)
    local playerIdentifier = GetIdentifier(source)

    local vehicle = nil
    if (enterWithVehicle) then
        vehicle = GetVehiclePedIsIn(player, false)
    end

    local property = GetPropertyById(property_id)
    local entrance = json.decode(property.entrance)
    entrance = vector3(entrance.x, entrance.y, entrance.z)
    local distance = #(playerCoords - entrance)

    local enteringWithVehicle = property.shell.vehicle_entrance ~= nil and enterWithVehicle and vehicle ~= nil

    if (distance > 2.5) then
        return {
            ret = false,
            notification = {
                title = 'Property',
                description = locale('not_close_to_enter'),
                status = 'error',
            }
        }
    end

    local permissionLevel = GetPlayerPropertyPermissionLevel(source, property)

    if (permissionLevel ~= nil) then
        if (enteringWithVehicle) then
            if (type(property.saved_vehicles) == 'string') then property.saved_vehicles = json.decode(property.saved_vehicles) end

            if (not property.shell.vehicle_limit or #property.saved_vehicles >= property.shell.vehicle_limit) then
                return {
                    ret = false,
                    notification = {
                        title = 'Property',
                        description = locale('property_full'),
                        status = 'error',
                    }
                }
            end

            local plate = GetVehicleNumberPlateText(vehicle)
            if (IsPlateInProperty(plate, property)) then
                return {
                    ret = false,
                    notification = {
                        title = 'Property',
                        description = locale('vehicle_already_in_property'),
                        status = 'error',
                    }
                }
            end

            if (vehicle) then
                local playersInVehicle = GetPlayersInVehicle(vehicle)
                for _,id in pairs(playersInVehicle) do
                    if (tonumber(id) ~= tonumber(source)) then
                        local identifier = GetIdentifier(id)
                        local playerPermissionLevel = GetPlayerPropertyPermissionLevel(identifier, property)
                        PlayerEnterProperty(property, {
                            identifier = identifier,
                            serverId = id,
                            name = PlayerName(id),
                            permissionLevel = playerPermissionLevel,
                        })

                        TriggerEvent("bnl-housing:event:playerEnteredProperty", id, property)

                        TriggerClientEvent("bnl-housing:client:handleEnter", id, {
                            property = property,
                            permissionLevel = playerPermissionLevel,
                            withVehicle = true
                        })
                    end
                end
            end
        end

        PlayerEnterProperty(property, {
            identifier = playerIdentifier,
            serverId = source,
            name = PlayerName(source),
            permissionLevel = permissionLevel,
        })

        if (enteringWithVehicle) then
            VehicleEnterProperty(property, {
                networkId = NetworkGetNetworkIdFromEntity(vehicle),
                plate = GetVehicleNumberPlateText(vehicle),
            })
        end

        -- TODO: MAKE THIS BETTER WORKS NOW THO
        CreateThread(function()
            Wait(1000)
            SpawnPropertyVehicles(property)
        end)

        TriggerEvent("bnl-housing:event:playerEnteredProperty", source, property)

        return {
            ret = true,
            property = property,
            permissionLevel = permissionLevel,
            withVehicle = enteringWithVehicle,
        }
    end

    return {
        ret = false,
        notification = {
            title = locale('property'),
            description = locale('no_access'),
            status = 'error',
        }
    }
end)

lib.callback.register('bnl-housing:server:exit', function(source, exitWithVehicle)
    local property = GetPropertyPlayerIsInside(source)
    if (not property) then return { ret = false } end

    local player = GetPlayerPed(source)
    PlayerExitProperty(property, GetIdentifier(source))

    local deleteVehicle = property.shell.vehicle_entrance == nil
    local vehicle, withVehicle = nil, false

    if (exitWithVehicle) then
        vehicle = GetVehiclePedIsIn(player, false)
        VehicleExitProperty(property, GetVehicleNumberPlateText(vehicle))
        withVehicle = IsPedVehicleDriver(player, vehicle)

        local playersInVehicle = GetPlayersInVehicle(vehicle)
        for _,id in pairs(playersInVehicle) do
            if (tonumber(id) ~= tonumber(source)) then
                local identifier = GetIdentifier(id)
                local playerPermissionLevel = GetPlayerPropertyPermissionLevel(identifier, property)
                PlayerExitProperty(property, identifier)

                TriggerEvent("bnl-housing:event:playerExitedProperty", id, property)

                TriggerClientEvent("bnl-housing:client:handleExit", id, {
                    ret = true,
                    withVehicle = true,
                    deleteVehicle = false,
                })
            end
        end
    end

    TriggerEvent("bnl-housing:event:playerExitedProperty", source, property)

    return {
        ret = true,
        withVehicle = withVehicle,
        deleteVehicle = deleteVehicle,
    }
end)

lib.callback.register("bnl-housing:server:knock", function(source, property_id)
    local player = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(player)
    local property = GetPropertyById(property_id)
    if (not property) then return end

    local entrance = json.decode(property.entrance)
    entrance = vector3(entrance.x, entrance.y, entrance.z)
    local distance = #(playerCoords - entrance)

    if (distance > 2.5) then
        return {
            ret = false,
            notification = {
                title = locale('property'),
                description = locale('not_close_enough'),
                status = 'error',
            }
        }
    end

    if (property.playersInside) then
        for _,player in pairs(property.playersInside) do
            if (player.permissionLevel == 'owner' or player.permissionLevel == 'key_owner') then
                TriggerClientEvent("bnl-housing:client:knocking", player.serverId)
            end
        end
    end

    return {
        ret = true,
        notification = {
            title = locale('property'),
            description = locale('knocking_notification'),
            status = 'Successs',
        }
    }
end)

lib.callback.register("bnl-housing:server:breakin", function(source, property_id)
    return {
        ret = true,
        notification = {
            title = locale('property'),
            description = "This feature is not yet implemented!",
            status = 'error',
        }
    }
end)

RegisterNetEvent("bnl-housing:server:giveKeys", function(player_id)
    local _source = source
    local player = GetIdentifier(player_id)
    local property = GetPropertyPlayerIsInside(_source)
    local sourceplr = FindPlayerInProperty(property, _source)

    if (not player or not property or not sourceplr) then return end

    if (sourceplr.permissionLevel == "owner") then
        local key_owners = json.decode(property.key_owners)

        for _,key_owner in pairs(key_owners) do
            if (key_owner.identifier == player) then
                TriggerClientEvent("bnl-housing:client:notify", _source, {
                    title = locale('property'),
                    description = locale('player_has_access'),
                    status = 'error',
                })
                return Logger.Warn(string.format("%s tried to give keys to %s, but they already have access to it.", PlayerName(_source), PlayerName(player_id)))
            end
        end

        local new_key_owner = {
            identifier = player,
            name = PlayerName(player_id),
            timestamp = os.time()
        }

        table.insert(key_owners, new_key_owner)
        property.key_owners = json.encode(key_owners)

        MySQL.update("UPDATE `bnl_housing` SET `key_owners` = @key_owners WHERE `id` = @id", {
            ['@key_owners'] = property.key_owners,
            ['@id'] = property.id
        })

        TriggerClientEvent("bnl-housing:client:notify", _source, {
            title = locale('property'),
            description = locale('gave_keys', new_key_owner.name),
            status = 'Successs',
        })

        Logger.Success(string.format("%s gave keys to %s", PlayerName(_source), PlayerName(player_id)))
        UpdateProperty(property)
    else
        Logger.Error(string.format("Player %s tried to give keys to player %s, but they don't have permission.", PlayerName(_source), PlayerName(player_id)))
        return
    end
end)

RegisterNetEvent("bnl-housing:server:takeKeys", function(player_id)
    local _source = source
    local player = player_id
    local property = GetPropertyPlayerIsInside(_source)
    local sourceplr = FindPlayerInProperty(property, _source)

    if (not player or not property or not sourceplr) then return end

    if (sourceplr.permissionLevel == "owner") then
        local key_owners = json.decode(property.key_owners)

        for i,key_owner in pairs(key_owners) do
            if (key_owner.identifier == player) then
                table.remove(key_owners, i)
                property.key_owners = json.encode(key_owners)

                MySQL.update("UPDATE `bnl_housing` SET `key_owners` = @key_owners WHERE `id` = @id", {
                    ['@key_owners'] = property.key_owners,
                    ['@id'] = property.id
                })

                TriggerClientEvent("bnl-housing:client:notify", _source, {
                    title = locale('property'),
                    description = locale('taken_keys', key_owner.name),
                    status = 'Successs',
                })

                Logger.Success(string.format("%s took keys from %s", PlayerName(_source), key_owner.name))
                UpdateProperty(property)
            end
        end
    else
        Logger.Error(string.format("Player %s tried to take keys from player %s, but they don't have permission.", PlayerName(_source), player_id))
        return
    end
end)

lib.callback.register("bnl-housing:server:take_keys_menu", function(source)
    local _source = source
    local property = GetPropertyPlayerIsInside(source)
    local player = FindPlayerInProperty(property, _source)

    if (player and player.permissionLevel == 'owner') then
        local keys = json.decode(property.key_owners)

        if (#keys == 0) then
            TriggerClientEvent("bnl-housing:client:notify", _source, {
                title = locale('property'),
                description = locale('no_key_owners'),
                status = 'error',
            })
            return
        end

        return {
            ret = true,
            keys = keys
        }
    end

    return {
        ret = false,
        notification = {
            title = locale('property'),
            description = locale('no_permission'),
            status = 'error',
        }
    }
end)

AddEventHandler('playerDropped', function (reason)
    local _source = source
    local player = GetIdentifier(_source)
    local property = GetPropertyPlayerIsInside(_source)

    if (not player or not property) then return end

    local data = {
        identifier = player,
        name = GetPlayerName(_source),
        permissionLevel = FindPlayerInProperty(property, player).permissionLevel,
        timestamp = os.time()
    }

    table.insert(property.saved_players, data)

    MySQL.update("UPDATE `bnl_housing` SET `saved_players` = @saved_players WHERE `id` = @id", {
        ['@saved_players'] = json.encode(property.saved_players),
        ['@id'] = property.id
    })

    PlayerExitProperty(property, player)
    UpdateProperty(property)
end)

RegisterNetEvent("bnl-housing:server:playerLoaded", function()
    local _source = source
    local playerIdentifier = GetIdentifier(_source)
    local data = FindSavedPlayer(playerIdentifier)

    if (not data) then return end

    if (data.ret) then
        local property = data.property
        local player = data.player

        if (type(property.saved_players) == 'string') then
            property.saved_players = json.decode(property.saved_players)
        end

        for i,saved_player in pairs(property.saved_players) do
            if (saved_player.identifier == player.identifier) then
                table.remove(property.saved_players, i)
                break
            end
        end

        MySQL.update("UPDATE `bnl_housing` SET `saved_players` = @saved_players WHERE `id` = @id", {
            ['@saved_players'] = json.encode(property.saved_players),
            ['@id'] = property.id
        })

        PlayerEnterProperty(property, {
            identifier = playerIdentifier,
            serverId = _source,
            name = PlayerName(_source),
            permissionLevel = player.permissionLevel,
        })

        -- TODO: MAKE THIS BETTER WORKS NOW THO
        CreateThread(function()
            Wait(1000)
            SpawnPropertyVehicles(property)
        end)

        TriggerClientEvent("bnl-housing:client:handleEnter", source, {
            property = property,
            permissionLevel = player.permissionLevel,
            withVehicle = false
        })

        TriggerEvent("bnl-housing:event:playerLoadedInProperty", _source, property)

        UpdateProperty(property)
    end
end)

-- SPECIAL PROPS
lib.callback.register("bnl-housing:server:openSafe", function(source, data)
    local property = GetPropertyPlayerIsInside(source)
    if (not property) then return end

    local player = FindPlayerInProperty(property, source)
    if (not player) then return end

    local prop = GetPropertyPropById(property, data.prop_id)

    if (prop) then
        if (prop.data.code) then
            if (prop.data.code == tonumber(data.code)) then
                local safe_id = 'property_' .. property.id
                exports.ox_inventory:RegisterStash(safe_id, 'Property Safe', 50, 1000  * 1000)
                return {
                    ret = true,
                    safe_id = safe_id
                }
            else
                return {
                    ret = false,
                    notification = {
                        title = locale('safe'),
                        description = locale('wrong_code'),
                        status = 'error',
                    }
                }
            end
        end
    end

    if (player.permissionLevel == "key_owner" or player.permissionLevel == "owner") then
        local safe_id = 'property_' .. property.id
        exports.ox_inventory:RegisterStash(safe_id, 'Property Safe', 50, 1000  * 1000)
        return {
            ret = true,
            safe_id = safe_id
        }
    else
        return {
            ret = false,
            notification = {
                title = locale('safe'),
                description = locale('no_permission'),
                status = 'error',
            }
        }
    end
end)

lib.callback.register("bnl-housing:server:setSafeCode", function(source, data)
    local property = GetPropertyPlayerIsInside(source)
    if (not property) then return end

    local player = FindPlayerInProperty(property, source)
    if (not player) then return end

    local prop = GetPropertyPropById(property, data.prop_id)
    if (prop) then
        if (not prop.data) then prop.data = {} end

        if (prop.data.code) then
            if (prop.data.code == tonumber(data.old_code)) then
                local new_code = tonumber(data.new_code)
                if (#tostring(new_code) ~= 4) then
                    return {
                        ret = false,
                        notification = {
                            title = locale('safe'),
                            description = locale('invalid_code'),
                            status = 'error',
                        }
                    }
                end
                prop.data.code = new_code
                UpdatePropertyProp(property, prop)
                return {
                    ret = true,
                    notification = {
                        title = locale('safe'),
                        description = locale('code_changed'),
                        status = 'success',
                    }
                }
            else
                return {
                    ret = false,
                    notification = {
                        title = locale('safe'),
                        description = locale('wrong_code'),
                        status = 'error',
                    }
                }
            end
        else
            local new_code = tonumber(data.code)
            if (#tostring(new_code) ~= 4) then
                return {
                    ret = false,
                    notification = {
                        title = locale('safe'),
                        description = locale('invalid_code'),
                        status = 'error',
                    }
                }
            end
            prop.data.code = new_code
            UpdatePropertyProp(property, prop)
            return {
                ret = true,
                notification = {
                    title = locale('safe'),
                    description = locale('code_changed'),
                    status = 'success',
                }
            }
        end
    end

    return {
        ret = false,
        notification = {
            title = locale('safe'),
            description = locale('error'),
            status = 'error',
        }
    }
end)