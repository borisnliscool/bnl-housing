RegisterNetEvent("bnl-housing:decoration:saveProp", function(_data)
    local _source = source
    local property = GetPropertyPlayerIsInside(_source)
    local permission = GetPlayerPropertyPermissionLevel(_source, property)

    if (not (permission == 'key_owner') and not (permission == 'owner')) then
        -- player doesn't have permission
        return
    end

    local prop = _data
    local id = GetHighestPropId(property) + 1
    prop.id = id
    
    InsertPropertyProp(property, prop)
end)