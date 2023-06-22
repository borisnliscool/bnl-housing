local isInPropertyVehicle = false

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
            Bridge.HelpNotification(locale("notification.property.exitWithVehicle", Config.Keybinds.exitGarage.name))

            if IsControlJustPressed(Config.Keybinds.exitGarage.padIndex, Config.Keybinds.exitGarage.control) then
                lib.callback.await("bnl-housing:server:property:exit", false, propertyVehicle.property)
            end
        end
    end
end)
