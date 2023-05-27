Player = {}
Player.__index = Player

function Player.new(source)
    local instance = setmetatable({}, Property)

    instance.identifier = Bridge.GetPlayerIdentifier(source)
    instance.name = Bridge.GetPlayerName(source)

    return instance
end
