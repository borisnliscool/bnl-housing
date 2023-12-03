Player = {}
Player.__index = Player

---@param source number
---@param property table
---@return Player
function Player.new(source, property)
    local instance = setmetatable({}, Player)

    instance.source = source
    instance.identifier = Bridge.GetPlayerIdentifier(source)
    instance.name = Bridge.GetPlayerName(source)
    instance.property = property
    instance.key = instance.property:getPlayerKey(source)

    return instance
end

---@param bucketId number
function Player:setBucket(bucketId)
    lib.print.verbose(("Setting %s's routing bucket to %s"):format(self.name, bucketId))
    SetPlayerRoutingBucket(self.source, bucketId)
end

---@return Entity
function Player:ped()
    return GetPlayerPed(self.source)
end

---Get the vehicle the player is in
---@return Entity
function Player:vehicle()
    return GetVehiclePedIsIn(self:ped(), false)
end

---Teleports the player into the property
function Player:warpIntoProperty()
    local data = Data.Shells[self.property.model]
    if not data then
        lib.print.error(("No data found for %s, check %s"):format(self.property.model, "data/shells.lua"))
        return false
    end

    lib.print.verbose(("Warping %s into property %s"):format(self.name, self.property.id))

    local coords = self.property.location + data.entrances.foot
    SetEntityCoords(self:ped(), coords.x, coords.y, coords.z - 1.0, true, false, false, false)
end

---Teleports the player outside of the property
function Player:warpOutOfProperty()
    lib.print.verbose(("Warping %s out of property %s"):format(self.name, self.property.id))

    local coords = self.property.entranceLocation
    SetEntityCoords(self:ped(), coords.x, coords.y, coords.z - 1.0, true, false, false, false)
end

---@param name string
---@param ... unknown
---@return unknown
function Player:triggerFunction(name, ...)
    return ClientFunctions[name](self.source, ...)
end

---@param value boolean
function Player:freeze(value)
    if value == nil then value = true end
    FreezeEntityPosition(self:ped(), value)
end

---@return number
function Player:getMoney()
    return Bridge.GetMoney(self.source)
end

---@param amount number
---@return unknown
function Player:removeMoney(amount)
    return Bridge.RemoveMoney(self.source, amount)
end
