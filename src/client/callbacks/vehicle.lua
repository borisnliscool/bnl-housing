lib.callback.register("bnl-housing:client:setVehicleProps", function(netId, props)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    return lib.setVehicleProperties(vehicle, props)
end)

lib.callback.register("bnl-housing:client:getVehicleProps", function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    return lib.getVehicleProperties(vehicle)
end)

lib.callback.register("bnl-housing:client:setVehicleUndriveable", function(netId, value)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    return SetVehicleUndriveable(vehicle, value)
end)
