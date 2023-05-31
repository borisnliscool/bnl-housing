lib.callback.register("bnl-housing:server:getProperties", function(source)
    local playerIdentifier = Bridge.GetPlayerIdentifier(source)

    return table.map(Properties, function(property)
        local data = property:getData()
        data.key = table.findOne(data.keys, function(key)
            return key.player == playerIdentifier
        end)
        data.keys = nil
        return data
    end)
end)

lib.callback.register("bnl-housing:server:getPropertyKey", function(source, property_id)
    local property = GetPropertyById(property_id)
    return property:getPlayerKey(source)
end)

lib.callback.register("bnl-housing:server:getPlayerName", function(_, playerId)
    return Bridge.GetPlayerName(playerId)
end)