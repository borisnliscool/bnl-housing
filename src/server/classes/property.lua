Property = {}
Property.__index = Property

function Property.new(data)
    local instance = setmetatable(Property, {})

    instance.id = data.id
    instance.model = data.model
    instance.entranceLocation = json.decode(data.entrance_location)
    instance.props = {}
    instance.bucketId = 1000 + data.id

    CreateThread(function()
        instance:spawnModel()
        instance:loadProps()
    end)

    return instance
end

--#region Model
function Property:destroyModel()
    if self.entity then
        DeleteEntity(self.entity)
    end
end

function Property:spawnModel()
    self:destroyModel()

    -- todo:
    --  think about where to place the entity, currently it's placed 25 units below
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

    -- wait for the entity to be created
    while not DoesEntityExist(entity) do Wait(10) end

    FreezeEntityPosition(entity, true)
    -- SetEntityRoutingBucket(entity, self.bucketId)

    self.location = GetEntityCoords(entity)
    self.entity = entity
end

--#endregion

--#region Props
function Property:destroyProps()
    for _, prop in pairs(self.props) do
        prop:destroy()
    end
end

function Property:loadProps()
    self:destroyProps()

    local databaseProps = MySQL.query.await("SELECT * FROM property_prop WHERE property_id = ?", { self.id })
    for _, propData in pairs(databaseProps) do
        local prop = Prop.new(propData, self)
        self.props[propData.id] = prop
    end
end

--#endregion

function Property:destroy()
    self:destroyModel()
    self:destroyProps()
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end

    Property:destroy()
end)