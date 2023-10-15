---Check if the player has a permission for a property.
---@type function[]
CheckPermission = {
    ---@param source number
    ---@param propertyId number
    ---@return boolean
    [PERMISSION.MEMBER] = function(source, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return false end

        ---@type Key
        local key = property:getPlayerKey(source)
        return
            key.permission == PERMISSION.MEMBER or
            key.permission == PERMISSION.RENTER or
            key.permission == PERMISSION.OWNER
    end,
    ---@param source number
    ---@param propertyId number
    ---@return boolean
    [PERMISSION.RENTER] = function(source, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return false end

        ---@type Key
        local key = property:getPlayerKey(source)
        return
            key.permission == PERMISSION.RENTER or
            key.permission == PERMISSION.OWNER
    end,
    ---@param source number
    ---@param propertyId number
    ---@return boolean
    [PERMISSION.OWNER] = function(source, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return false end

        ---@type Key
        local key = property:getPlayerKey(source)
        return key.permission == PERMISSION.OWNER
    end,
}

---@param vehicle Entity
---@param props table
function SetVehicleProps(vehicle, props)
    -- todo
    -- Maybe check if the vehicle has a driver and then send that
    -- player a set properties event, otherwise use this.
    -- We could also send a callback to the client and after that
    -- check if the props are correct, and otherwise send it again
    Entity(vehicle).state:set("setVehicleProperties", props, true)
end

---@param vehicle Entity
---@return table
function GetVehicleProps(vehicle)
    return lib.callback.await(
        "bnl-housing:client:getVehicleProps",
        NetworkGetEntityOwner(vehicle),
        NetworkGetNetworkIdFromEntity(vehicle)
    )
end

---@return string
function GenerateRentCronJob()
    local currentWeekday = tonumber(os.date("%w", os.time())) + 1
    return ("%s %s * * %s"):format(os.date("%M"), os.date("%H"), currentWeekday)
end

---Returns a table with all the players in a given vehicle, key is player ped, value is player server id.
---@param vehicle Entity
---@return { [integer]: integer }
function GetPlayersInVehicle(vehicle)
    local allPeds = {}
    table.map(Bridge.GetAllPlayers(), function(player)
        allPeds[GetPlayerPed(player)] = player
    end)

    local ret = {}
    for i = -1, 16 do
        ret[i] = allPeds[GetPedInVehicleSeat(vehicle, i)]
    end

    return ret
end
