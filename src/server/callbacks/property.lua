lib.callback.register("bnl-housing:server:property:exit", function(source, property_id)
    local property = GetPropertyById(property_id)
    return property:exit(source)
end)

lib.callback.register("bnl-housing:server:property:getLocation", function(_, property_id)
    local property = GetPropertyById(property_id)
    return property.location
end)

-- todo: permissions
lib.callback.register("bnl-housing:server:property:getKeys", function(_, property_id)
    local property = GetPropertyById(property_id)
    return table.map(property.keys, function(key)
        return {
            id = key.id,
            property_id = key.property_id,
            permission = key.permission,
            player = Bridge.GetPlayerNameFromIdentifier(key.player),
            serverId = Bridge.GetServerIdFromIdentifier(key.player),
        }
    end)
end)

-- todo: permissions
lib.callback.register("bnl-housing:server:getOutsidePlayers", function(_, property_id)
    local property = GetPropertyById(property_id)
    local players = property:getOutsidePlayers()
    return table.map(
        players,
        function(player)
            return {
                name = Bridge.GetPlayerName(player),
                id = player
            }
        end
    )
end)

-- todo: permissions
lib.callback.register("bnl-housing:server:property:invite", function(source, playerId)
    local property = GetPropertyPlayerIsIn(source)
    local accepted = lib.callback.await("bnl-housing:client:handleInvite", playerId, property:getData().address)
    if not accepted then return end

    property:enter(source)
end)

-- todo: permissions
lib.callback.register("bnl-housing:server:property:giveKey", function(source, playerId)
    local property = GetPropertyPlayerIsIn(source)
    property:givePlayerKey(playerId)
end)

-- todo: permissions
lib.callback.register("bnl-housing:server:property:removeKey", function(source, keyId)
    local property = GetPropertyPlayerIsIn(source)
    property:removePlayerKey(keyId)
end)