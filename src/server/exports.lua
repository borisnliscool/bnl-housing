exports("getProperty", function(id)
    return GetPropertyById(id):getData()
end)

exports("createProperty", Property.new)

exports("getPropertyPlayerIsIn", function(playerId)
    return GetPropertyPlayerIsIn(playerId)
end)

exports("getPropertiesVehicleIsIn", function(vehiclePlate)
    local propertyIds = {}

    for id in pairs(Properties) do
        local property = Properties[id] --[[@as Property]]

        local vehicles = table.find(property.vehicles, function(vehicle)
            return vehicle.props.plate == vehiclePlate
        end)

        if vehicles then
            for _ = 1, #vehicles do
                table.insert(propertyIds, property.id)
            end
        end
    end

    return propertyIds
end)

exports("warpPlayerIntoProperty", function(playerId, propertyId)
    return GetPropertyById(propertyId):enter(playerId)
end)

exports("warpPlayerOutOfProperty", function(playerId, propertyId)
    local property = GetPropertyById(propertyId) or GetPropertyPlayerIsIn(playerId)
    return property and property:exit(playerId)
end)

exports("registerSpecialProp", RegisterSpecialProp)
