---@param bagName string
---@return number | nil
local function getVehicleFromBagName(bagName)
    local entityTimeout = GetGameTimer()
    while not GetEntityFromStateBagName(bagName) do
        Wait(0)

        if GetGameTimer() - entityTimeout > 10000 then
            return
        end
    end

    local vehicle = GetEntityFromStateBagName(bagName)
    if not vehicle then return end

    local networkOwnerTimeout = GetGameTimer()
    while NetworkGetEntityOwner(vehicle) ~= PlayerId() do
        Wait(0)

        if GetGameTimer() - networkOwnerTimeout > 10000 then
            return
        end
    end

    return vehicle
end


AddStateBagChangeHandler('setVehicleProperties', '', function(bagName, _, value)
    if not value then return end

    local vehicle = getVehicleFromBagName(bagName)
    if not vehicle then return end

    lib.setVehicleProperties(vehicle, value)
end)

AddStateBagChangeHandler('undriveable', '', function(bagName, _, value)
    if not value then return end

    local vehicle = getVehicleFromBagName(bagName)
    if not vehicle then
        return
    end

    SetVehicleUndriveable(vehicle, value)
end)
