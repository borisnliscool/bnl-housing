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

    instance._metadata = type(data.metadata) == "string" and json.decode(data.metadata) or data.metadata or {}
    instance.metadata = instance:metadataAPI()

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
    SetEntityRotation(
        entity,
        self.rotation.x,
        self.rotation.y,
        self.rotation.z,
        2,
        true
    )

    SetEntityRoutingBucket(entity, self.property.bucketId)

    self.entity = entity

    if ServerSpecialProps[self.model] then
        CallSpecialPropHandlers(
            ServerSpecialProps[self.model].handlers?.server?.spawn,
            self:getData()
        )
    end
end

---Delete the entity
function Prop:destroy()
    if ServerSpecialProps[self.model] then
        CallSpecialPropHandlers(
            ServerSpecialProps[self.model].handlers?.server?.destroy,
            self:getData()
        )
    end

    return DoesEntityExist(self.entity) and DeleteEntity(self.entity)
end

function Prop:getData()
    return {
        id = self.id,
        model = self.model,
        location = self.location,
        rotation = self.rotation,
        metadata = self.metadata,
        propertyId = self.property.id
    }
end

---@return PropMetadataAPI
function Prop:metadataAPI()
    return {
        ---@param key string
        get = function(key)
            return exports["bnl-housing"]:getPropMetadataItem(self.property.id, self.id, true, key)
        end,

        ---@param key string
        ---@param value any
        set = function(key, value)
            return exports["bnl-housing"]:setPropMetadataItem(self.property.id, self.id, true, key, value)
        end,

        clear = function()
            return exports["bnl-housing"]:clearPropMetadata(self.property.id, self.id, true)
        end,

        ---@param key string
        getPrivate = function(key)
            return exports["bnl-housing"]:getPropMetadataItem(self.property.id, self.id, false, key)
        end,

        ---@param key string
        ---@param value any
        setPrivate = function(key, value)
            return exports["bnl-housing"]:setPropMetadataItem(self.property.id, self.id, false, key, value)
        end,

        clearPrivate = function()
            return exports["bnl-housing"]:clearPropMetadata(self.property.id, self.id, false)
        end
    }
end
