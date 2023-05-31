Player = {}
Player.__index = Player

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
    Debug.Log(("Setting %s's routing bucket to %s"):Format(self.name, bucketId))

    SetPlayerRoutingBucket(self.source, bucketId)
end

function Player:ped()
    return GetPlayerPed(self.source)
end

function Player:warpIntoProperty()
    Debug.Log(("Warping %s into property %s"):Format(self.name, self.property.id))

    local data = Data.Shells[self.property.model]
    if not data then
        return Debug.Error(("No data found for %s, check %s"):Format(self.property.model, "data/shells.lua"))
    end

    local coords = self.property.location + data.entrances.foot
    SetEntityCoords(self:ped(), coords.x, coords.y, coords.z - 1.0, true, false, false, false)
end

function Player:warpOutOfProperty()
    Debug.Log(("Warping %s out of property %s"):Format(self.name, self.property.id))

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