local ox_inventory = exports.ox_inventory
allPropertyLocations = nil; properties = nil; shells = nil;

Citizen.CreateThread(function()
    shells = data('shells')

    MySQL.query('SELECT * FROM bnl_housing', function(result)
        if result then
            properties = result

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
                for _,shell in pairs(shells) do
                    if (property.shell_id == shell.id) then
                        property.shell = shell
                        break
                    end
                end
            end

            TriggerEvent('bnl-housing:server:onPropertiesLoaded', properties)
        end
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

        Citizen.CreateThread(function()
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

RegisterNetEvent("bnl-housing:server:acceptInvite", function()
    local _source = source
    for i=1,#propertyInvites do
        local invite = propertyInvites[i]
        if (tonumber(invite.player) == tonumber(_source)) then
            local property = GetPropertyById(invite.property_id)
            TriggerClientEvent("bnl-housing:client:enterProperty", _source, property, "visitor")
            Logger.Succes(string.format("Player %s accepted invite to property #%s.", PlayerName(invite.source), property.id))
            PlayerEnterProperty(property, {
                identifier = GetIdentifier(_source),
                serverId = _source,
                name = PlayerName(_source),
                permissionLevel = 'visitor',
            })
            table.remove(propertyInvites, i)
        end
    end
end)

lib.callback.register('bnl-housing:server:enter', function(source, property_id)
    local player = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(player)
    local playerIdentifier = GetIdentifier(source)

    local property = GetPropertyById(property_id)
    local entrance = json.decode(property.entrance)
    entrance = vector3(entrance.x, entrance.y, entrance.z)
    local distance = #(playerCoords - entrance)

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
    
    if (playerIdentifier == property.owner) then
        PlayerEnterProperty(property, {
            identifier = playerIdentifier,
            serverId = source,
            name = PlayerName(source),
            permissionLevel = 'owner',
        })

        return {
            ret = true,
            property = property,
            permissionLevel = 'owner',
        }
    end

    for _,key_owner in pairs(json.decode(property.key_owners)) do
        if (playerIdentifier == key_owner.identifier) then
            PlayerEnterProperty(property, {
                identifier = playerIdentifier,
                serverId = source,
                name = PlayerName(source),
                permissionLevel = 'key_owner',
            })

            return {
                ret = true,
                property = property,
                permissionLevel = 'key_owner',
            }
        end
    end

    if (ox_inventory:Search(source, 'property_key', {property_id = property_id})) then
        PlayerEnterProperty(property, {
            identifier = playerIdentifier,
            serverId = source,
            name = PlayerName(source),
            permissionLevel = 'key_owner',
        })

        return {
            ret = true,
            property = property,
            permissionLevel = 'key_owner',
        }
    end

    return {
        ret = false,
        notification = {
            title = 'Property',
            description = locale('no_access'),
            status = 'error',
        }
    }
end)

RegisterNetEvent("bnl-housing:server:enter", function(property_id)
    local _source = source
    local ped = GetPlayerPed(_source)
    local pedcoord = GetEntityCoords(ped)
    local playerIdentifier = GetIdentifier(_source)

    local property = GetPropertyById(property_id)
    local entrance = json.decode(property.entrance)
    entrance = vector3(entrance.x, entrance.y, entrance.z)

    local distance = #(pedcoord - entrance)
    
    if (distance > 2.0) then
        TriggerClientEvent("bnl-housing:client:notify", _source, {
            title = 'Property',
            description = locale('not_close_to_enter'),
            status = 'error',
        })
        return Logger.Error(string.format("%s tried to enter property #%s but isn't close enough (%sm)", PlayerName(_source), property_id, math.round(distance, 2)))
    end

    if (playerIdentifier == property.owner) then
        TriggerClientEvent("bnl-housing:client:enterProperty", _source, property, "owner")
        PlayerEnterProperty(property, {
            identifier = playerIdentifier,
            serverId = _source,
            name = PlayerName(_source),
            permissionLevel = 'owner',
        })
        return Logger.Succes(string.format("%s entered property #%s, they are the owner", PlayerName(_source), property_id))
    end

    for _,key_owner in pairs(json.decode(property.key_owners)) do
        if (playerIdentifier == key_owner.identifier) then
            TriggerClientEvent("bnl-housing:client:enterProperty", _source, property, "key_owner")
            PlayerEnterProperty(property, {
                identifier = playerIdentifier,
                serverId = _source,
                name = PlayerName(_source),
                permissionLevel = 'key_owner',
            })
            return Logger.Succes(string.format("%s entered property #%s, because they are a key owner", PlayerName(_source), property_id))
        end
    end

    if (ox_inventory:Search(_source, 'property_key', {property_id = property_id})) then
        TriggerClientEvent("bnl-housing:client:enterProperty", _source, property, "key_owner")
        PlayerEnterProperty(property, {
            identifier = playerIdentifier,
            serverId = _source,
            name = PlayerName(_source),
            permissionLevel = 'key_owner',
        })
        return Logger.Succes(string.format("%s entered property #%s with a key item", PlayerName(_source), property_id))
    end

    TriggerClientEvent("bnl-housing:client:notify", _source, {
        title = 'Property',
        description = locale('no_access'),
        status = 'error',
    })
end)

lib.callback.register('bnl-housing:server:exit', function(source)
    local property = GetPropertyPlayerIsInside(source)
    if (not property) then return false end
    
    PlayerExitProperty(GetPropertyById(property.id), GetIdentifier(source))
    return true
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
                title = 'Property',
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
            title = 'Property',
            description = locale('knocking_notification'),
            status = 'success',
        }
    }
end)

lib.callback.register("bnl-housing:server:breakin", function(source, property_id)
    return {
        ret = true,
        notification = {
            title = 'Property',
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
                    title = 'Property',
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

        MySQL.query("UPDATE `bnl_housing` SET `key_owners` = @key_owners WHERE `id` = @id", {
            ['@key_owners'] = property.key_owners,
            ['@id'] = property.id
        })

        TriggerClientEvent("bnl-housing:client:notify", _source, {
            title = 'Property',
            description = locale('gave_keys', new_key_owner.name),
            status = 'success',
        })

        Logger.Succes(string.format("%s gave keys to %s", PlayerName(_source), PlayerName(player_id)))

        -- TODO: Update the player that has been given the keys
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

                MySQL.query("UPDATE `bnl_housing` SET `key_owners` = @key_owners WHERE `id` = @id", {
                    ['@key_owners'] = property.key_owners,
                    ['@id'] = property.id
                })

                TriggerClientEvent("bnl-housing:client:notify", _source, {
                    title = 'Property',
                    description = locale('taken_keys', key_owner.name),
                    status = 'success',
                })

                Logger.Succes(string.format("%s took keys from %s", PlayerName(_source), key_owner.name))

                -- TODO: Update the player that the keys were taken from
            end
        end
    else
        Logger.Error(string.format("Player %s tried to take keys from player %s, but they don't have permission.", PlayerName(_source), player_id))
        return
    end
end)

lib.callback.register("bnl-housing:server:take_keys_menu", function()
    local _source = source
    local property = GetPropertyPlayerIsInside(source)
    local player = FindPlayerInProperty(property, _source)

    if (player and player.permissionLevel == 'owner') then
        local keys = json.decode(property.key_owners)
        
        if (#keys == 0) then
            TriggerClientEvent("bnl-housing:client:notify", _source, {
                title = 'Property',
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
            title = 'Property',
            description = locale('no_permission'),
            status = 'error',
        }
    }
end)