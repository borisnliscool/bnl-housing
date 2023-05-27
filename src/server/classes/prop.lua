Prop = {}
Prop.__index = Prop

function Prop.new(data, property)
    local instance = setmetatable({}, Prop)

    instance.property = property
    instance.id = data.id
    instance.model = data.model
    instance.location = json.decode(data.location)
    instance.rotation = json.decode(data.rotation)
    instance.metadata = json.decode(data.metadata)

    return instance
end

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

function Prop:destroy()
    DeleteEntity(self.entity)
end

-- this will later add functionality for interactive props
function Prop:interact(source)
end
