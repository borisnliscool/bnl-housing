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

function Player:setBucket(bucketId)
    SetPlayerRoutingBucket(self.source, bucketId)
end