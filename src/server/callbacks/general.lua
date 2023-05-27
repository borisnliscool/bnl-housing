lib.callback.register(cache.resource .. ":server:getProperties", function(source)
    local playerIdentifier = Bridge.GetPlayerIdentifier(source)

    return table.map(Properties, function(property)
        return {
            id = property.id,
            entranceLocation = property.entranceLocation,
            propertyType = property.propertyType,
            key = table.findOne(property.keys, function(key)
                return key.player == playerIdentifier
            end)
        }
    end)
end)

lib.callback.register(cache.resource .. ":server:getPropertyKey", function(source, property_id)
    local property = GetPropertyById(property_id)
    return property:getPlayerKey(source)
end)