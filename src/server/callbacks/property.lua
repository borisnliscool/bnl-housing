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
                player = Bridge.GetPlayerNameFromIdentifier(key.player) or "",
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
    function(_, propertyId, propId)
        local property = GetPropertyById(propertyId)
        return property and NetworkGetNetworkIdFromEntity(
            table.findOne(property.props, function(prop)
                return prop.id == propId
            end).entity
        )
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:decoration:addProp",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId, propData)
        local property = GetPropertyById(propertyId)
        return property and property:addProp(propData)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:decoration:removeProp",
    CheckPermission[PERMISSION.MEMBER],
    function(_, propertyId, propId)
        local property = GetPropertyById(propertyId)
        return property and property:removeProp(propId)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:decoration:payForProp",
    CheckPermission[PERMISSION.MEMBER],
    function(source, _, propModel)
        local propData = GetPropFromModel(propModel)
        if not propData then return end
        Bridge.RemoveMoney(source, math.abs(propData.price))
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:sell", CheckPermission[PERMISSION.OWNER],
    function(_, propertyId, price)
        local property = GetPropertyById(propertyId)
        return property and property:markForSale(price)
    end
)

RegisterMiddlewareCallback("bnl-housing:server:property:rentout", CheckPermission[PERMISSION.OWNER],
    function(_, propertyId, price)
        local property = GetPropertyById(propertyId)
        return property and property:markForRent(price)
    end
)
