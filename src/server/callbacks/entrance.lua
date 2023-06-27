RegisterMiddlewareCallback("bnl-housing:server:entrance:enter",
    CheckPermission[PERMISSION.MEMBER],
    function(source, propertyId)
        local property = GetPropertyById(propertyId)
        return property and property:enter(source)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:entrance:knock", function(source, propertyId)
    local property = GetPropertyById(propertyId)
    return property and property:knock(source)
end)
