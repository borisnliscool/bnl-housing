-- todo: permissions
lib.callback.register("bnl-housing:server:entrance:enter", function(source, propertyId)
    local property = GetPropertyById(propertyId)
    return property:enter(source)
end)

lib.callback.register("bnl-housing:server:entrance:knock", function(source, propertyId)
    local property = GetPropertyById(propertyId)
    property:knock(source)
end)
