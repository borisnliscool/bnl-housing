Player = {}
Player.__index = Player

function Player.new(source, property)
    local instance = setmetatable({}, Property)

    instance.identifier = Bridge.GetPlayerIdentifier(source)
    instance.name = Bridge.GetPlayerName(source)
    instance.property = property
    instance.key = instance.property:getPlayerKey(source)

    return instance
end
