lib.callback.register("bnl-housing:client:setVehicleProps", function(netId, props)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    lib.setVehicleProperties(vehicle, props)
end)
