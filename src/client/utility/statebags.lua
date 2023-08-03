--- Taken from ox_lib
--- https://github.com/overextended/ox_lib/blob/master/resource/vehicleProperties/client.lua
AddStateBagChangeHandler('setVehicleProperties', '', function(bagName, _, value)
    if not value or not GetEntityFromStateBagName then return end

    local entity = GetEntityFromStateBagName(bagName)
    local networked = not bagName:find('localEntity')

    if networked and NetworkGetEntityOwner(entity) ~= cache.playerId then return end

    if lib.setVehicleProperties(entity, value) then
        Entity(entity).state:set('setVehicleProperties', nil, true)
    end
end)
