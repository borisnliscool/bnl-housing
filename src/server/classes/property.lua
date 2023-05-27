Property = {}
Property.__index = Property

function Property.new(data)
    local instance = setmetatable({}, Property)

    instance.id = data.id
    instance.model = data.model
    instance.entranceLocation = json.decode(data.entrance_location)
    instance.propertyType = data.property_type
    instance.bucketId = 1000 + data.id
    instance.props = {}
    instance.keys = {}

    CreateThread(function()
        instance:spawnModel()
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
    if not self.props then return end

    for _, prop in pairs(self.props) do
        prop:destroy()
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
