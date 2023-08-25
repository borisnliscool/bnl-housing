exports("getProperty", function(id)
    return GetPropertyById(id):getData()
end)

exports("getPropertyPlayerIsIn", function(playerId)
    return GetPropertyPlayerIsIn(playerId)
end)

exports("warpPlayerIntoProperty", function(playerId, propertyId)
    return GetPropertyById(propertyId):enter(playerId)
end)

exports("warpPlayerOutOfProperty", function(playerId, propertyId)
    local property = GetPropertyById(propertyId) or GetPropertyPlayerIsIn(playerId)
    return property and property:exit(playerId)
end)
