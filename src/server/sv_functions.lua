--- Get the player's identifier used in the resource
-- @param source The player's server-id
-- @return a string value The player's identifier
function GetIdentifier(source)
    for _,id in pairs(GetPlayerIdentifiers(source)) do
        if (string.match(id, 'license:')) then
            return id:gsub('license:', '')
        end
    end
    return nil
end

-- TODO: Framework detection for this
function PlayerName(source)
    return GetPlayerName(source)
end

function UpdateAllPlayerBlips()
    local players = {}

    for _,property in pairs(properties) do
        local blips = {}
        local sprite = property.type.blip.normal.sprite or 1
        local name = property.type.name or locale('property')

        if (type(property.key_owners) == 'string') then
            property.key_owners = json.decode(property.key_owners)
        end
        for _,key_owner in pairs(property.key_owners) do
            local player = GetPlayerFromIdentifier(key_owner.identifier)
            if (player) then
                blips[player] = {
                    coord = JsonCoordToVector3(property.entrance),
                    sprite = sprite,
                    color = 3,
                    name = name,
                    scale = 1.0,
                    category = 'bnl-housing:property',
                    short = false
                }
            end
        end

        if (property.owner) then
            local player = GetPlayerFromIdentifier(property.owner)
            if (player) then
                blips[player] = {
                    coord = JsonCoordToVector3(property.entrance),
                    sprite = sprite,
                    color = 2,
                    name = name,
                    scale = 1.0,
                    category = 'bnl-housing:property',
                    short = false
                }
            end
        end

        for player,blip in pairs(blips) do
            if (not players[player]) then
                players[player] = {}
            end
            table.insert(players[player], blip)
        end
    end

    for player, blips in pairs(players) do
        TriggerClientEvent("bnl-housing:client:setAllPropertyBlips", player, blips)
    end
end

function UpdateProperty(newProperty)
    local property_id = newProperty.id

    properties[property_id] = newProperty
    local property = properties[property_id]

    if (not property) then return end

    if (property.playersInside) then
        for _,player in pairs(property.playersInside) do
            TriggerClientEvent('bnl-housing:client:updateProperty', player.serverId, property)
        end
    end

    return true
end

--- Get the property with the given id
-- @param property_id The property's id
-- @return a table value The property
function GetPropertyById(property_id)
    if (type(property_id) == 'string') then
        property_id = tonumber(property_id)
    end

    return properties[property_id]
end

--- Get the property the player is in
-- @param source The player's server-id
-- @return a table value The property
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

--- Get the player inside the property
-- @param property The property
-- @param source The player's server-id
-- @return a table value The player
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

function PlayerEnterProperty(property, player)
    if property.playersInside == nil then
        property.playersInside = {}
    end

    for _,playerInProperty in pairs(property.playersInside) do
        if (playerInProperty.identifier == player.identifier) then
            return
        end
    end

    table.insert(property.playersInside, player)
    UpdateProperty(property)
    return true
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

    table.insert(property.vehicles, vehicle)
    UpdateProperty(property)

    return true
end

RegisterNetEvent("baseevents:enteredVehicle", function(_, _, _, netId)
    local property = GetPropertyPlayerIsInside(source)
    if (property) then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        FreezeEntityPosition(vehicle, false)
    end
end)

RegisterNetEvent("baseevents:leftVehicle", function(_, _, _, netId)
    local property = GetPropertyPlayerIsInside(source)
    if (property) then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if (IsVehicleEmpty(vehicle)) then
            FreezeEntityPosition(vehicle, true)
        end
    end
end)

function SpawnPropertyVehicles(property)
    if (property.playersInside == nil) then
        property.playersInside = {}
    end

    if (#property.playersInside ~= 1) then
        return
    end

    if (property.vehicles == nil) then
        property.vehicles = {}
    end

    if (property.saved_vehicles == nil) then
        property.saved_vehicles = {}
    end

    if (type(property.saved_vehicles) == 'string') then
        property.saved_vehicles = json.decode(property.saved_vehicles)
    end

    Logger.Info("Spawning " .. #property.saved_vehicles .. " vehicles for property #" .. property.id)

    for _,vehicleInProperty in pairs(property.saved_vehicles) do
        CreateThread(function()
            local v3 = vector3(vehicleInProperty.location.x, vehicleInProperty.location.y, vehicleInProperty.location.z)
            local location = JsonCoordToVector3(property.entrance) - lowerBy + v3 + vector3(0.0, 0.0, 1.5)

            local heading = vehicleInProperty.heading
            local vehicle = CreateVehicle(vehicleInProperty.model, location, heading, true, false)

            repeat
                Wait(10)
            until vehicle ~= nil and DoesEntityExist(vehicle) and NetworkGetNetworkIdFromEntity(vehicle) ~= nil

            local vehicleNetworkId = NetworkGetNetworkIdFromEntity(vehicle)
            local newNetOwner = property.playersInside[1].serverId
            TriggerClientEvent('bnl-housing:client:setNetworkOwner', newNetOwner, vehicleNetworkId)
            TriggerClientEvent('bnl-housing:client:setVehicleProps', newNetOwner, vehicleNetworkId, vehicleInProperty)

            FreezeEntityPosition(vehicle, true)

            table.insert(property.vehicles, {
                networkId = vehicleNetworkId,
                plate = vehicleInProperty.plate,
            })

            -- This is needed for some anticheats. So if you're having trouble with the vehicles, try uncommenting this.
            -- Wait(300)
        end)
    end

    UpdateProperty(property)
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

    if (type(property.saved_vehicles) == 'string') then
        property.saved_vehicles = json.decode(property.saved_vehicles)
    end

    local savedVehicles = {}
    for _,vehicle in pairs(property.vehicles) do
        local vehicleEntity = NetworkGetEntityFromNetworkId(vehicle.networkId)

        if (not DoesEntityExist(vehicleEntity)) then
            goto continue
        end

        local vehicleOwner = NetworkGetEntityOwner(vehicleEntity)

        table.insert(vehicleDataRequests, vehicle)
        TriggerClientEvent('bnl-housing:client:requestVehicleData', vehicleOwner, vehicle)

        local timeout = false
        CreateThread(function()
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

        if (GetPedInVehicleSeat(vehicleEntity, -1) == 0 or GetPedInVehicleSeat(vehicleEntity, -1) == nil) then
            if (not timeout) then
                vehicleData[vehicle.networkId].location = GetEntityCoords(vehicleEntity) - JsonCoordToVector3(property.entrance) + lowerBy
                vehicleData[vehicle.networkId].heading = GetEntityHeading(vehicleEntity)
                table.insert(savedVehicles, vehicleData[vehicle.networkId])
            end

            DeleteEntity(vehicleEntity)
        end

        ::continue::
    end

    property.vehicles = {}

    if (next(savedVehicles) ~= nil) then
        property.saved_vehicles = savedVehicles

        MySQL.update("UPDATE `bnl_housing` SET `vehicles` = @vehicles WHERE `id` = @id", {
            ['@vehicles'] = json.encode(property.saved_vehicles),
            ['@id'] = property.id
        })
    end

    UpdateProperty(property)
end

function PlayerExitProperty(property, playerIdentifier)
    if (property.playersInside == nil) then
        property.playersInside = {}
        return false
    end

    local removed = false
    for i,v in pairs(property.playersInside) do
        if (v.identifier == playerIdentifier) then
            table.remove(property.playersInside, i)
            removed = true
        end
    end

    if (#property.playersInside == 0) then
        SavePropertyVehicles(property)
    else
        for _,vehicle in pairs(property.vehicles) do
            local vehicleEntity = NetworkGetEntityFromNetworkId(vehicle.networkId)
            if (IsVehicleEmpty(vehicleEntity)) then
                local newNetOwner = property.playersInside[1]
                TriggerClientEvent('bnl-housing:client:setNetworkOwner', newNetOwner.serverId, vehicle.networkId)
            end
        end
    end

    UpdateProperty(property)
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

    UpdateProperty(property)
    return false
end

--- Function to update a specific prop in the property table.
-- @param property The property to update.
-- @param prop The prop to update.
-- @return nothing
function UpdatePropertyProp(property, prop)
    if (property.decoration == nil) then
        property.decoration = {}
    end

    if (type(property.decoration) == 'string') then
        property.decoration = json.decode(property.decoration)
    end

    for i,v in pairs(property.decoration) do
        if (v.id == prop.id) then
            property.decoration[i] = prop
            break
        end
    end

    MySQL.update("UPDATE `bnl_housing` SET `decoration` = @decoration WHERE `id` = @id", {
        ['@decoration'] = json.encode(property.decoration),
        ['@id'] = property.id
    })

    UpdateProperty(property)
end

-- Function to insert a prop into a property
-- @param property The property to insert
-- @param prop The prop to insert
-- return nothing
function InsertPropertyProp(property, prop)
    if (property.decoration == nil) then
        property.decoration = {}
    end

    if (type(property.decoration) == 'string') then
        property.decoration = json.decode(property.decoration)
    end

    table.insert(property.decoration, prop)

    MySQL.update("UPDATE `bnl_housing` SET `decoration` = @decoration WHERE `id` = @id", {
        ['@decoration'] = json.encode(property.decoration),
        ['@id'] = property.id
    })

    UpdateProperty(property)
end

-- Function to get the highest prop id form a decoration table
-- @param decoration Decoration to check
-- @return number
function GetHighestPropId(property)
    if (property.decoration == nil) then
        property.decoration = {}
    end

    if (type(property.decoration) == 'string') then
        property.decoration = json.decode(property.decoration)
    end

    local highestPropId = 0
    for _,prop in pairs(property.decoration) do
        if (tonumber(prop.id) > highestPropId) then
            highestPropId = tonumber(prop.id)
        end
    end
    return highestPropId
end

--- Check if the given plate is in any property
-- @param plate The plate to check.
-- @return table if the plate is in a property, false otherwise.
function IsPlateInAnyProperty(plate)
    for _,property in pairs(properties) do
        for _,vehicle in pairs(property.saved_vehicles) do
            if (vehicle.plate == plate) then
                return property
            end
        end
    end
    return false
end

--- Check if the given plate is in the given property
-- @param plate The plate to check.
-- @param property The property to check.
-- @return table if the plate is in the property, false otherwise.
function IsPlateInProperty(plate, property)
    for _,vehicle in pairs(property.saved_vehicles) do
        if (vehicle.plate == plate) then
            return true
        end
    end
    return false
end

function FindSavedPlayer(identifier)
    for _,property in pairs(properties) do
        for _,player in pairs(property.saved_players) do
            if (player.identifier == identifier) then
                return {
                    ret = true,
                    property = property,
                    player = player,
                }
            end
        end
    end
    return nil
end

--- Get the player's permission level for the given property
-- @param player The player to check.
-- @param property The property to check.
-- @return string The permission level.
function GetPlayerPropertyPermissionLevel(player, property)
    local playerIdentifier = player
    local permissionLevel = nil

    if (type(player) == 'number') then
        playerIdentifier = GetIdentifier(player)
        if (next(exports.ox_inventory) ~= nil) then
            if (exports.ox_inventory:Search(source, 'property_key', 'count',  {property_id = property_id}) > 0) then
                permissionLevel = 'key_owner'
            end
        end
    end

    if (type(property.key_owners) == 'string') then
        property.key_owners = json.decode(property.key_owners)
    end
    for _,key_owner in pairs(property.key_owners) do
        if (playerIdentifier == key_owner.identifier) then
            permissionLevel = 'key_owner'
        end
    end

    if (playerIdentifier == property.owner) then
        permissionLevel = 'owner'
    end

    return permissionLevel
end

function GetPlayerServerId(player)
    for _,id in pairs(GetPlayers()) do
        if (GetPlayerPed(id) == player) then
            return id
        end
    end
    return nil
end

function GetPlayerFromIdentifier(identifier)
    for _,id in pairs(GetPlayers()) do
        if (GetIdentifier(id) == identifier) then
            return id
        end
    end
    return nil
end

function GetPlayersInsideProperty(property)
    local players = {}
    for _,player in pairs(property.playersInside) do
        table.insert(players, player.serverId)
    end
    return players
end

-- Taken from ox_fuel by @Overextended. All credit goes to them!
-- I take no credit for this code. (Changed little a bit)
-- https://overextended.github.io/docs/
RegisterNetEvent('bnl-housing:setState', function(netid, fuel)
	local vehicle = NetworkGetEntityFromNetworkId(netid)
	local state = vehicle and Entity(vehicle).state

	if state and not state.fuel and GetEntityType(vehicle) == 2 and NetworkGetEntityOwner(vehicle) == source then
		state:set('fuel', fuel > 100 and 100 or fuel, true)
	end
end)

exports("GetIdentifier", GetIdentifier)
exports("PlayerName", PlayerName)
exports("GetPropertyById", GetPropertyById)
exports("GetPropertyPlayerIsInside", GetPropertyPlayerIsInside)
exports("GetPlayersInsideProperty", GetPlayersInsideProperty)
exports("FindPlayerInProperty", FindPlayerInProperty)
exports("UpdatePropertyProp", UpdatePropertyProp)
exports("IsPlateInAnyProperty", IsPlateInAnyProperty)
exports("IsPlateInProperty", IsPlateInProperty)
exports("GetPlayerPropertyPermissionLevel", GetPlayerPropertyPermissionLevel)