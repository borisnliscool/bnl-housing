lib.callback.register("bnl-housing:decoration:saveProp", function(source, _data)
    local _source = source
    local property = GetPropertyPlayerIsInside(_source)
    local permission = GetPlayerPropertyPermissionLevel(_source, property)

    if (not (permission == 'key_owner') and not (permission == 'owner')) then
        -- player doesn't have permission
        return
    end

    local modelData = props[_data.category][_data.model]
    if (modelData) then
        local itemName = modelData.itemRequired
        if (itemName) then
            local itemCount = modelData.itemCount or 1
            local playerItemCount = exports.ox_inventory:Search(_source, 'count', itemName, modelData.itemMetadata or nil) >= itemCount
            
            if (playerItemCount and playerItemCount >= itemCount) then
                exports.ox_inventory:RemoveItem(_source, itemName, itemCount, modelData.itemMetadata or nil)
            else
                return {ret = false} -- Player doesn't have enough of this item
            end
        end
    end

    local id = GetHighestPropId(property) + 1
    local prop = {
        x = _data.x,
        y = _data.y,
        z = _data.z,
        w = _data.w,
        model = _data.model,
        id = id
    }
    
    InsertPropertyProp(property, prop)

    return { ret = true }
end)

RegisterNetEvent("bnl-housing:decoration:deleteProp", function(propId)
    local _source = source
    local property = GetPropertyPlayerIsInside(_source)
    local permission = GetPlayerPropertyPermissionLevel(_source, property)

    if (not (permission == 'key_owner') and not (permission == 'owner')) then
        -- player doesn't have permission
        return
    end

    if (type(property.decoration) == 'string') then
        property.decoration = json.decode(property.decoration)
    end

    for id, prop in pairs(property.decoration) do
        if (prop.id == propId) then
            property.decoration[id] = nil
        end
    end

    MySQL.update("UPDATE `bnl_housing` SET `decoration` = @decoration WHERE `id` = @id", {
        ['@decoration'] = json.encode(property.decoration),
        ['@id'] = property.id
    })

    UpdateProperty(property)
end)