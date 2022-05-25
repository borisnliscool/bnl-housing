function GetIdentifier(source)
    for _,id in pairs(GetPlayerIdentifiers(source)) do 
        if string.match(id, 'license:') then 
            return id:gsub('license:', '') 
        end 
    end
    return nil
end

function GetPropertyById(property_id)
    for _,property in pairs(properties) do
        if property.id == property_id then
            return property
        end
    end
    return nil
end

function PlayerEnterProperty(property, player)
    if property.playersInside == nil then
        property.playersInside = {}
    end
    return table.insert(property.playersInside, player)
end

function PlayerExitProperty(property, playerId)
    if property.playersInside == nil then
        property.playersInside = {}
        return false
    end

    for i,v in pairs(property.playersInside) do
        if v.identifier == playerId then
            return table.remove(property.playersInside, i)
        end
    end

    return false
end

function GetPropertyPlayerIsInside(player)
    for _,property in pairs(properties) do
        if property.playersInside ~= nil then
            for _,playerId in pairs(property.playersInside) do
                if playerId.identifier == GetIdentifier(player) then
                    return property
                end
            end
        end
    end
    return nil
end

function FindPlayerInProperty(property, player)
    if property.playersInside == nil then
        property.playersInside = {}
        return nil
    end

    for _,plr in pairs(property.playersInside) do
        if (type(player) == 'number') then
            if plr.identifier == GetIdentifier(player) then
                return plr
            end
        elseif (type(player) == 'string') then
            if plr.identifier == player then
                return plr
            end
        end
    end

    return nil
end

function PlayerName(source)
    return GetPlayerName(source)
end