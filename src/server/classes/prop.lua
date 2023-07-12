Prop = {}
Prop.__index = Prop

---@param data table
---@param property Property
---@return Prop
function Prop.new(data, property)
    local instance = setmetatable({}, Prop)

    instance.property = property
    instance.id = data.id
    instance.model = data.model
    local location = type(data.location) == "string" and json.decode(data.location) or data.location
    instance.location = vector3(location.x, location.y, location.z)
    local rotation = type(data.location) == "string" and json.decode(data.rotation) or data.rotation
    instance.rotation = vector3(rotation.x, rotation.y, rotation.z)
    instance.metadata = type(data.location) == "string" and json.decode(data.metadata) or data.metadata

    return instance
end

---Spawn the prop
function Prop:spawn()
    local entity = CreateObject(
        self.model,
        self.property.location.x + self.location.x,
        self.property.location.y + self.location.y,
        self.property.location.z + self.location.z,
        true,
        true,
        false
    )

    -- wait for the entity to be created
    while not DoesEntityExist(entity) do Wait(10) end

    FreezeEntityPosition(entity, true)
    SetEntityRoutingBucket(entity, self.property.bucketId)

    SetEntityRotation(
        entity,
        self.rotation.x,
        self.rotation.y,
        self.rotation.z,
        2,
        true
    )

    self.entity = entity
end

---Delete the entity
function Prop:destroy()
    return DoesEntityExist(self.entity) and DeleteEntity(self.entity)
end

function Prop:getData()
    return {
        id = self.id,
        model = self.model,
        location = self.location,
        rotation = self.rotation,
        metadata = self.metadata,
    }
end
