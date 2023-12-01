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

--- Special props

exports("getPropMetadataItem", function(propertyId, propId, public, key)
    local property = GetPropertyById(propertyId)
    if not property then error("property not found") end

    local prop = table.findOne(property.props, function(p)
        return p.id == propId
    end) --[[@as Prop?]]
    if not prop then error("prop not found") end

    if not prop.metadata[public and "public" or "private"] then
        prop.metadata[public and "public" or "private"] = {}
    end

    if not key or key == "" then
        return prop.metadata[public and "public" or "private"]
    end

    return prop.metadata[public and "public" or "private"][key]
end)

exports("setPropMetadataItem", function(propertyId, propId, public, key, value)
    local property = GetPropertyById(propertyId)
    if not property then error("property not found") end

    local prop = table.findOne(property.props, function(p)
        return p.id == propId
    end) --[[@as Prop?]]
    if not prop then error("prop not found") end

    if not prop.metadata[public and "public" or "private"] then
        prop.metadata[public and "public" or "private"] = {}
    end

    prop.metadata[public and "public" or "private"][key] = value
    DB.updatePropertyProp(prop.metadata, prop.id)

    -- Update the metadata on all players in the property
    property:triggerUpdate(table.map(property.players, function(player)
        return player.source
    end))
end)

exports("clearPropMetadataItem", function(propertyId, propId, public)
    local property = GetPropertyById(propertyId)
    if not property then error("property not found") end

    local prop = table.findOne(property.props, function(p)
        return p.id == propId
    end) --[[@as Prop?]]
    if not prop then error("prop not found") end

    prop.metadata[public and "public" or "private"] = {}
    DB.updatePropertyProp(prop.metadata, prop.id)

    -- Update the metadata on all players in the property
    property:triggerUpdate(table.map(property.players, function(player)
        return player.source
    end))
end)
