lib.callback.register(cache.resource .. ":server:property:exit", function(source, property_id)
    local property = GetPropertyById(property_id)
    return property:exit(source)
end)

lib.callback.register(cache.resource .. ":server:property:getLocation", function(_, property_id)
    local property = GetPropertyById(property_id)
    return property.location
end)
