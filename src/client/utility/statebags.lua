---@param bagName string
---@param value any
local function getValidEntityFromStateBag(bagName, value)
    if not value or not GetEntityFromStateBagName then
        return
    end

    local entity = GetEntityFromStateBagName(bagName)
    local networked = not bagName:find('localEntity')

    if networked and NetworkGetEntityOwner(entity) ~= cache.playerId then
        return
    end

    return entity
end

AddStateBagChangeHandler('setVehicleProperties', '', function(bagName, _, v)
    local entity = getValidEntityFromStateBag(bagName, v)
    if entity and lib.setVehicleProperties(entity, v) then
        Entity(entity).state:set('setVehicleProperties', nil, true)
    end
end)

AddStateBagChangeHandler('undriveable', '', function(bagName, _, v)
    local entity = getValidEntityFromStateBag(bagName, v)
    if entity then
        SetVehicleUndriveable(entity, v)
    end
end)
