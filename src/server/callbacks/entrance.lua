-- todo: permissions
lib.callback.register("bnl-housing:server:entrance:enter", function(source, property_id)
    local property = GetPropertyById(property_id)
    return property:enter(source)
end)

lib.callback.register("bnl-housing:server:entrance:knock", function(source, property_id)
    local property = GetPropertyById(property_id)
    property:knock(source)
end)
