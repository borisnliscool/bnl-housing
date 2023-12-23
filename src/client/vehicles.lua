local isInPropertyVehicle = false

---@param entity Entity
---@return boolean
function IsVehicleBlacklisted(entity)
    return
        lib.table.contains(Config.VehicleBlacklist.classes, GetVehicleClass(entity)) or
        lib.table.contains(Config.VehicleBlacklist.models, GetEntityModel(entity))
end

lib.onCache('vehicle', function(vehicle)
    if not vehicle then
        isInPropertyVehicle = false
        return
    end

    local propertyVehicle = Entity(vehicle).state["propertyVehicle"]
    if not propertyVehicle then return end
    isInPropertyVehicle = true

    while isInPropertyVehicle do
        Wait(0)

        if cache.seat == -1 then
            ShowHelpNotification(locale("notification.property.exitWithVehicle", Config.Keybinds.exitGarage.name))

            if IsControlJustPressed(Config.Keybinds.exitGarage.padIndex, Config.Keybinds.exitGarage.control) then
                lib.callback.await("bnl-housing:server:property:exit", false, propertyVehicle.property)
            end
        end
    end
end)
