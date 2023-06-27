RegisterMiddlewareCallback("bnl-housing:server:getProperties", function(source)
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

RegisterMiddlewareCallback("bnl-housing:server:getPropertyKey", function(source, propertyId)
    local property = GetPropertyById(propertyId)
    return property and property:getPlayerKey(source)
end)

RegisterMiddlewareCallback("bnl-housing:server:getPlayerName", function(_, playerId)
    return Bridge.GetPlayerName(playerId)
end)