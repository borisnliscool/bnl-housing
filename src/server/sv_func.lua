function GetIdentifier(source)
    for _,id in pairs(GetPlayerIdentifiers(source)) do 
        if (string.match(id, 'license:')) then 
            return id:gsub('license:', '') 
        end 
    end
    return nil
end

function GetPropertyById(property_id)
    for _,property in pairs(properties) do
        if (property.id == property_id) then
            return property
        end
    end
    return nil
end

function PlayerEnterProperty(property, player)
    if property.playersInside == nil then
        property.playersInside = {}
    end

    for _,playerInProperty in pairs(property.playersInside) do
        if (playerInProperty.identifier == player.identifier) then
            return
        end
    end

    return table.insert(property.playersInside, player)
end

function VehicleEnterProperty(property, vehicle)
    if (property.vehicles == nil) then
        property.vehicles = {}
    end

    for _,vehicleInProperty in pairs(property.vehicles) do
        if (vehicleInProperty.plate == vehicle.plate) then
            return
        end
    end

    return table.insert(property.vehicles, vehicle)
end

local vehicleDataRequests = {}
local vehicleData = {}

RegisterNetEvent("bnl-housing:server:postVehicleData", function(vehicle, data)
    for i=1,#vehicleDataRequests do
        local vehicleDataRequest = vehicleDataRequests[i]

        if (vehicleDataRequest.networkId == vehicle.networkId) then
            vehicleData[vehicle.networkId] = data

            table.remove(vehicleDataRequests, i)
            break
        end
    end
end)

function SavePropertyVehicles(property)
    if (property.vehicles == nil) then
        return
    end

    local allVehicles = {}
    for _,vehicle in pairs(property.vehicles) do
        local vehicleEntity = NetworkGetEntityFromNetworkId(vehicle.networkId)

        if (not DoesEntityExist(vehicleEntity)) then
            goto continue
        end

        local vehicleOwner = NetworkGetEntityOwner(vehicleEntity)

        table.insert(vehicleDataRequests, vehicle)
        TriggerClientEvent('bnl-housing:client:requestVehicleData', vehicleOwner, vehicle)

        local timeout = false
        Citizen.CreateThread(function()
            Wait(1000)
            if (vehicleData[vehicle.networkId] == nil) then
                timeout = true

                for i=1,#vehicleDataRequests do
                    local vehicleDataRequest = vehicleDataRequests[i]

                    if (vehicleDataRequest.networkId == vehicle.networkId) then
                        table.remove(vehicleDataRequests, i)
                        break
                    end
                end
            end
        end)

        repeat
            Wait(10)
        until vehicleData[vehicle.networkId] ~= nil or timeout
        
        table.insert(allVehicles, vehicleData[vehicle.networkId])
        DeleteEntity(vehicleEntity)

        ::continue::
    end

    property.vehicles = json.encode(allVehicles)

    MySQL.update("UPDATE `bnl_housing` SET `vehicles` = @vehicles WHERE `id` = @id", {
        ['@vehicles'] = property.vehicles,
        ['@id'] = property.id
    })
end

function PlayerExitProperty(property, playerId)
    if (property.playersInside == nil) then
        property.playersInside = {}
        return false
    end

    local removed = false
    for i,v in pairs(property.playersInside) do
        if (v.identifier == playerId) then
            table.remove(property.playersInside, i)
            removed = true
        end
    end

    if (#property.playersInside == 0) then
        SavePropertyVehicles(property)
    end

    return removed
end

function VehicleExitProperty(property, vehiclePlate)
    if (property.vehicles == nil) then
        property.vehicles = {}
        return false
    end

    for _,vehicle in pairs(property.vehicles) do
        if (vehicle.plate == vehiclePlate) then
            return table.remove(property.vehicles, i)
        end
    end

    return false
end

function GetPropertyPlayerIsInside(player)
    for _,property in pairs(properties) do
        if (property.playersInside ~= nil) then
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
    if (property.playersInside == nil) then
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

-- TODO: Framework detection for this
function PlayerName(source)
    return GetPlayerName(source)
end