Property = {}
Property.__index = Property

-- todo
-- create a Property.new function that creates
-- a new property in the db and returns that
function Property.load(data)
    local instance = setmetatable({}, Property)

    instance.id = data.id
    instance.model = data.model
    instance.entranceLocation = table.tovector(json.decode(data.entrance_location))
    instance.propertyType = data.property_type
    -- todo
    -- find a better way to get a new bucket id,
    -- is there even a limit to the amount of
    -- buckets that are generated?
    instance.bucketId = 1000 + data.id
    instance.props = {}
    instance.keys = {}
    instance.players = {}
    instance.isSpawning = false
    instance.isSpawned = false
    instance.location, instance.entity = nil, nil

    SetRoutingBucketPopulationEnabled(instance.bucketId, false)

    CreateThread(function()
        instance:loadProps()
        instance:loadKeys()
    end)

    return instance
end

function Property:save()
    -- Saving props
    if self.props and #self.props > 0 then
        for _, prop in pairs(self.props) do
            MySQL.prepare.await("UPDATE property_prop SET metadata = ? WHERE id = ?", {
                json.encode(prop.metadata),
                prop.id
            })
        end
    end
end

--#region Model
function Property:destroyModel()
    if self.entity then
        DeleteEntity(self.entity)
    end
end

function Property:spawnModel()
    self:destroyModel()

    -- todo
    --  think about where to place the entity, currently it's placed 50 units below
    --  the location, but this could cause issues with water under the map
    local entity = CreateObject(
        self.model,
        self.entranceLocation.x,
        self.entranceLocation.y,
        self.entranceLocation.z - 50.0,
        true,
        true,
        false
    )

    -- todo
    --  sometimes this infinite loops because the model doesn't exist
    --  we need to check if it fails like 5 times, and if so
    --  send an error message and return
    while not DoesEntityExist(entity) do Wait(10) end

    FreezeEntityPosition(entity, true)
    SetEntityRoutingBucket(entity, self.bucketId)

    self.location = GetEntityCoords(entity)
    self.entity = entity
end

--#endregion

--#region Props
function Property:destroyProps()
    if not self.props then return end

    for _, prop in pairs(self.props) do
        prop:destroy()
    end
end

function Property:spawnProps()
    for _, prop in pairs(self.props) do
        prop:spawn()
    end
end

function Property:loadProps()
    self:destroyProps()

    local databaseProps = MySQL.query.await("SELECT * FROM property_prop WHERE property_id = ?", { self.id })
    self.props = table.map(databaseProps, function(propData)
        return Prop.new(propData, self)
    end)
end

--#endregion

--#region Getters
function Property:loadKeys()
    local databaseKeys = MySQL.query.await("SELECT * FROM property_key WHERE property_id = ?", { self.id })
    self.keys = databaseKeys
end

---@param source number
function Property:getPlayerKey(source)
    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    return table.findOne(self.keys, function(key)
        return key.player == playerIdentifier
    end) or nil
end

---@param source number
function Property:getPlayer(source)
    if not self.players or not next(self.players) then
        return
    end

    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    return self.players[playerIdentifier]
end

--#endregion

---@param source number
function Property:isPlayerInside(source)
    return self:getPlayer(source) ~= nil
end

---@param source number
function Property:enter(source)
    if self:isPlayerInside(source) then
        return
    end

    local player = Player.new(source, self)

    -- tweak timings for faster enter
    player:triggerFunction("FadeOut", 500)
    Wait(500)
    player:freeze(true)

    player:setBucket(self.bucketId)

    -- todo
    -- I'm not totally conviced of this method
    -- of spawning the shell just in time
    if not self.isSpawned and not self.isSpawning then
        self.isSpawning = true
        self:spawnModel()
        self:spawnProps()
        self.isSpawned = true
    end

    player:warpIntoProperty()
    player:triggerFunction("SetupInPropertyPoints", self.id)
    self.players[player.identifier] = player

    -- tweak timings for faster enter
    Wait(250)
    player:freeze(false)
    player:triggerFunction("FadeIn", 500)

    return true
end

---@param source number
function Property:exit(source)
    if not self:isPlayerInside(source) then
        return
    end

    local player = self:getPlayer(source)
    if player == nil then
        return true
    end

    -- tweak timings for faster exit
    player:triggerFunction("FadeOut", 500)
    Wait(500)
    player:freeze(true)

    player:setBucket(0)
    player:triggerFunction("RemoveInPropertyPoints", self.id)
    player:warpOutOfProperty()
    self.players[player.identifier] = nil

    -- tweak timings for faster exit
    player:freeze(false)
    Wait(250)
    player:triggerFunction("FadeIn", 500)

    return true
end

function Property:destroy()
    self:destroyModel()
    self:destroyProps()
end

function Property:getData()
    return {
        id = self.id,
        entranceLocation = self.entranceLocation,
        location = self.location,
        propertyType = self.propertyType,
        model = self.model,
        keys = self.keys
    }
end
