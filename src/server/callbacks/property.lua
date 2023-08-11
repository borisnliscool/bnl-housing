RegisterMiddlewareCallback("bnl-housing:server:property:inside", function(source)
    return GetPropertyPlayerIsIn(source):getData()
end)

RegisterMiddlewareCallback("bnl-housing:server:property:exit", function(source, propertyId)
    local property = GetPropertyById(propertyId)
    return property and property:exit(source)
end)

RegisterMiddlewareCallback("bnl-housing:server:property:getLocation", function(_, propertyId)
    local property = GetPropertyById(propertyId)
    return property and property.location
end)

RegisterMiddlewareCallback("bnl-housing:server:property:getKeys",
    CheckPermission[PERMISSION.RENTER],
    function(_, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return end

        return table.map(property.keys, function(key)
            return {
                id = key.id,
                property_id = key.property_id,
                permission = key.permission,
                player = Bridge.GetPlayerNameFromIdentifier(key.player),
                serverId = Bridge.GetServerIdFromIdentifier(key.player),
            }
        end)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:getOutsidePlayers",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return end

        local players = property:getOutsidePlayers()
        return table.map(
            players,
            function(player)
                return {
                    name = Bridge.GetPlayerName(player),
                    id = player
                }
            end
        )
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:invite",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId, playerId)
        local property = GetPropertyById(propertyId)
        if not property then return end

        local accepted = lib.callback.await("bnl-housing:client:handleInvite", playerId, property:getData().address)
        if not accepted then return end

        property:enter(source)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:giveKey",
    CheckPermission[PERMISSION.RENTER],
    function(_, propertyId, playerId)
        local property = GetPropertyById(propertyId)
        if not property then return end

        property:givePlayerKey(playerId)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:removeKey",
    CheckPermission[PERMISSION.RENTER],
    function(_, propertyId, keyId)
        local property = GetPropertyById(propertyId)
        return property and property:removePlayerKey(keyId)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:buyProperty",
    function(source, propertyId)
        local property = GetPropertyById(propertyId)
        return property and property:buy(source)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:rentProperty",
    function(source, propertyId)
        local property = GetPropertyById(propertyId)
        return property and property:rent(source)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:decoration:getPropEntity",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId, propId)
        local property = GetPropertyById(propertyId)
        return property and NetworkGetNetworkIdFromEntity(
            table.findOne(property.props, function(prop)
                return prop.id == propId
            end).entity
        )
    end
)

-- todo
--  maybe move the following two functions
--  to Property:addProp and Property:deleteProp?
RegisterMiddlewareCallback("bnl-housing:server:property:decoration:addProp",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId, propData)
        local property = GetPropertyById(propertyId)
        if not property then return end

        propData.location = propData.location - property.location

        local ret = DB.insertPropertyProp(
            property.id,
            propData.model,
            propData.location,
            propData.rotation
        )

        local prop = Prop.new({
            id = ret.insertId,
            model = propData.model,
            location = propData.location,
            rotation = propData.rotation,
            metadata = {}
        }, property)

        table.insert(property.props, prop)
        prop:spawn()

        property:triggerUpdate(table.map(property.players, function(player)
            return player.source
        end))
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:decoration:deleteProp",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId, propId)
        local property = GetPropertyById(propertyId)
        if not property then return end

        local prop, key = table.findOne(property.props, function(_prop)
            return _prop.id == propId
        end)
        if not prop or not key then return end

        DB.deletePropertyProp(propId)

        prop:destroy()
        table.remove(property.props, key)

        property:triggerUpdate(table.map(property.players, function(player)
            return player.source
        end))
    end
)
