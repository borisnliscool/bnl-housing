lib.callback.register("bnl-housing:server:property:exit", function(source, property_id)
    local property = GetPropertyById(property_id)
    return property:exit(source)
end)

lib.callback.register("bnl-housing:server:property:getLocation", function(_, property_id)
    local property = GetPropertyById(property_id)
    return property.location
end)

-- todo: permissions
lib.callback.register("bnl-housing:server:property:getKeys", function(source, property_id)
    local property = GetPropertyById(property_id)
    return table.map(property.keys, function(key)
        return {
            id = key.id,
            property_id = key.property_id,
            permission = key.permission,
            player = Bridge.GetPlayerNameFromIdentifier(key.player)
        }
    end)
end)
