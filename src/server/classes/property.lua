local MySQL = MySQL

Property = {}
Property.__index = Property

-- todo
--  create a Property.new function that creates
--  a new property in the db and returns that

---@param data table
---@return Property
function Property.load(data)
    local instance = setmetatable({}, Property)

    instance.id = data.id
    instance.model = data.model
    instance.shellData = Data.Shells[instance.model]
    if instance.shellData.vehicleSlots then
        instance.shellData.vehicleSlots = table.map(instance.shellData.vehicleSlots, function(slot, id)
            slot.id = id
            return slot
        end)
    end

    instance.entranceLocation = table.tovector(json.decode(data.entrance_location))
    instance.propertyType = data.property_type
    instance.address = {
        zipcode = data.zipcode,
        streetName = data.street_name,
        buildingNumber = data.building_number
    }
    instance.bucketId = 1000 + data.id
    instance.props = {}
    instance.keys = {}
    instance.links = {}
    instance.players = {}
    instance.vehicles = {}
    instance.isSpawning = false
    instance.isSpawned = false
    instance.isSpawningVehicles = false
    instance.vehiclesSpawned = false
    instance.location, instance.entity = nil, nil
    instance.saleData, instance.rentData = nil, nil

    SetRoutingBucketPopulationEnabled(instance.bucketId, false)

    CreateThread(function()
        instance:loadProps()
        instance:loadKeys()
        instance:loadLinks()
        instance:loadVehicleData()
        instance:loadTransactions()
    end)

    return instance
end

--#region Model
---Destroys the property shell entity
function Property:destroyModel()
    if self.entity then
        DeleteEntity(self.entity)
    end
end

---Spawns the property shell entity
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

--#region Keys
---Load the property keys
function Property:loadKeys()
    local databaseKeys = MySQL.query.await("SELECT * FROM property_key WHERE property_id = ?", { self.id })
    self.keys = databaseKeys
end

---Get the property key for the given player
---@param source number
---@return Key
function Property:getPlayerKey(source)
    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    local foundKey = table.findOne(self.keys, function(key)
        return key.player == playerIdentifier
    end)
    if foundKey then return foundKey end

    return {
        property_id = self.id,
        permission = PERMISSION.VISITOR,
        player = playerIdentifier,
    }
end

---Give the player a key to the property
---@param source number
function Property:givePlayerKey(source)
    -- check if the player already has a key
    if self:getPlayerKey(source).permission ~= PERMISSION.VISITOR then
        return
    end

    ---@type Key
    local key = {
        property_id = self.id,
        player = Bridge.GetPlayerIdentifier(source),
        permission = PERMISSION.MEMBER
    }

    local id = MySQL.insert.await("INSERT INTO property_key (property_id, player, permission) VALUES (?, ?, ?)", {
        key.property_id,
        key.player,
        key.permission
    })
    key.id = id

    table.insert(self.keys, key)
    Debug.Log(Format("Gave key to %s for property %s", key.player, self.id))

    -- todo
    --  refresh the properties on the client side
    --  to fix the blips for the reciever
end

---Remove the key for the player
---@param keyId number
function Property:removePlayerKey(keyId)
    -- if the player has no key, there's nothing to remove
    ---@type Key?
    local key, id = table.findOne(self.keys, function(v, k)
        return v.id == keyId
    end)
    if not key or not id then return end

    MySQL.query.await("DELETE FROM property_key WHERE id = ?", { key.id })
    table.remove(self.keys, id)

    Debug.Log(Format("Removed key %s from property %s", key.id, self.id))

    -- todo
    --  refresh the properties on the client side
end

--#endregion

--#region Vehicles
---Load the data for all the vehicles
function Property:loadVehicleData()
    self.vehicles = table.map(
        MySQL.query.await("SELECT * FROM property_vehicle WHERE property_id = ?", { self.id }),
        function(d)
            d.slot = self.shellData.vehicleSlots[d.slot]
            d.props = json.decode(d.props)
            return d
        end
    )
end

---Spawn a vehicle inside the property
---@param data table
---@return Entity
function Property:spawnVehicle(data)
    local coords = self.location + vec3(data.slot.location.x, data.slot.location.y, data.slot.location.z)
    local vehicle = CreateVehicle(data.props.model, coords.x, coords.y, coords.z, data.slot.location.w, true, false)

    while not DoesEntityExist(vehicle) do
        Wait(10)
    end

    SetEntityRoutingBucket(vehicle, self.bucketId)

    Entity(vehicle).state["propertyVehicle"] = {
        property = self.id,
        slot = data.slot
    }

    lib.callback.await("bnl-housing:client:setVehicleUndriveable",
        NetworkGetEntityOwner(vehicle),
        NetworkGetNetworkIdFromEntity(vehicle),
        true
    )

    lib.callback.await(
        "bnl-housing:client:setVehicleProps",
        NetworkGetEntityOwner(vehicle),
        NetworkGetNetworkIdFromEntity(vehicle),
        data.props
    )

    return vehicle
end

---Spawn all the property vehicles
function Property:spawnVehicles()
    self:destroyVehicles()

    for _, data in pairs(self.vehicles) do
        if data.slot then
            local vehicle = self:spawnVehicle(data)
            data.entity = vehicle
        end
    end
end

---Spawn a vehicle outside the property
---@param props table
---@return Entity
function Property:spawnOutsideVehicle(props)
    local vehicle = CreateVehicle(props.model, self.entranceLocation.x, self.entranceLocation.y, self.entranceLocation.z,
        self.entranceLocation.w, true, false)

    while not DoesEntityExist(vehicle) do
        Wait(10)
    end

    SetEntityRoutingBucket(vehicle, 0)

    lib.callback.await(
        "bnl-housing:client:setVehicleProps",
        NetworkGetEntityOwner(vehicle),
        NetworkGetNetworkIdFromEntity(vehicle),
        props
    )

    return vehicle
end

---Destroy all the vehicles in the property
function Property:destroyVehicles()
    for _, vehicle in pairs(self.vehicles) do
        DeleteEntity(vehicle.entity)
    end
end

---Get the first free vehicle slot in the property
---@return VehicleSlot?
function Property:getFirstFreeVehicleSlot()
    local slots = self.shellData.vehicleSlots

    for _, slot in pairs(slots) do
        local vehicle = table.find(self.vehicles, function(veh)
            return veh.slot.id == slot.id
        end)

        if #vehicle == 0 then
            return slot
        end
    end
end

--#endregion

--#region Player Entry and Exiting

---Make the player enter the property
---@param source number
---@param settings table
---@return boolean
function Property:enter(source, settings)
    if self:isPlayerInside(source) then
        return false
    end

    local propertyPlayerIsIn = GetPropertyPlayerIsIn(source)
    if propertyPlayerIsIn ~= nil then
        -- todo
        --  make the transition smoother, currently its doing two
        --  transitions and you see the outside for a split second
        propertyPlayerIsIn:exit(source, {
            transitionIn = false,
        })
    end

    local player = Player.new(source, self)

    local vehicle = GetVehiclePedIsIn(player:ped(), false)
    local isDriver = GetPedInVehicleSeat(vehicle, -1) == player:ped()
    local handleVehicle = vehicle and DoesEntityExist(vehicle) and isDriver
    local spawnedVehicle, vehicleProps = nil, nil

    if handleVehicle then
        if #self.shellData.vehicleSlots == #self.vehicles then
            -- this garage is full
            player:triggerFunction("HelpNotification", locale("notification.property.noVehicleSpace"))
            return false
        end

        vehicleProps = lib.callback.await(
            "bnl-housing:client:getVehicleProps",
            source,
            NetworkGetNetworkIdFromEntity(vehicle)
        )
    end

    player:triggerFunction("StartBusySpinner", "Loading property...")
    player:triggerFunction("FadeOut", 500)

    Wait(500)

    player:freeze(true)
    player:setBucket(self.bucketId)

    -- todo
    --  I'm not totally conviced of this method
    --  of spawning the shell just in time
    if not self.isSpawned and not self.isSpawning then
        self.isSpawning = true
        self:spawnModel()
        self:spawnProps()
        self.isSpawned = true
    end

    if not self.vehiclesSpawned and not self.isSpawningVehicles then
        self.isSpawningVehicles = true
        self:spawnVehicles()
        self.vehiclesSpawned = true
    end

    -- todo
    --  handle passenger entering when driver enters the property
    if handleVehicle then
        local slot = self:getFirstFreeVehicleSlot()
        if not slot then
            Debug.Error("Could not find a slot for the vehicle, this shouldn't happen!")
            return false
        end

        local vehicleData = {
            props = vehicleProps,
            slot = slot,
        }

        spawnedVehicle = self:spawnVehicle(vehicleData)
        vehicleData.entity = spawnedVehicle

        table.insert(self.vehicles, vehicleData)

        CreateThread(function()
            MySQL.query.await("INSERT INTO property_vehicle (property_id, slot, props) VALUES (?, ?, ?)", {
                self.id,
                slot.id,
                json.encode(vehicleProps)
            })
        end)

        -- I don't know why, but this needs to be down here
        -- otherwise the vehicleProps don't work propperly
        DeleteEntity(vehicle)
        TaskWarpPedIntoVehicle(player:ped(), spawnedVehicle, -1)
    end

    if not handleVehicle then
        player:warpIntoProperty()
    end

    player:triggerFunction("SetupInPropertyPoints", self.id)

    if self.shellData.minimap then
        player:triggerFunction("StartMinimapOverlay", self.shellData.minimap, self.location, 1)
    end

    self.players[player.identifier] = player

    Wait(500)

    player:freeze(false)
    if not settings or settings.transitionIn ~= false then
        player:triggerFunction("FadeIn", 500)
    end
    player:triggerFunction("BusyspinnerOff")

    if handleVehicle then
        TaskLeaveVehicle(player:ped(), spawnedVehicle, 0)
    end

    return true
end

---Make the player leave the property
---@param source number
---@param settings table
---@return boolean
function Property:exit(source, settings)
    if not self:isPlayerInside(source) then
        return false
    end

    local player = self:getPlayer(source)
    if player == nil then
        return true
    end

    player:triggerFunction("StartBusySpinner", "Exiting property...")
    player:triggerFunction("FadeOut", 500)
    player:freeze(true)

    Wait(500)

    -- Handling vehicle stuff
    local vehicle = player:vehicle()
    local vehicleState = Entity(vehicle).state["propertyVehicle"]
    local isDriver = GetPedInVehicleSeat(vehicle, -1) == player:ped()
    local handleVehicle = vehicle and DoesEntityExist(vehicle) and isDriver and vehicleState ~= nil
    local spawnedVehicle = nil

    player:setBucket(0)
    player:triggerFunction("RemoveInPropertyPoints", self.id)
    player:triggerFunction("StopMinimapOverlay")

    -- todo
    --  handle all the passengers
    if handleVehicle then
        local vehicleData, index = table.findOne(self.vehicles, function(veh)
            return veh.slot.id == vehicleState.slot.id
        end)
        table.remove(self.vehicles, index)

        if vehicleData == nil then
            Debug.Error("Couldn't find vehicleData for vehicle", vehicle)
            return false
        end

        DeleteEntity(vehicleData.entity)
        spawnedVehicle = self:spawnOutsideVehicle(vehicleData.props)

        CreateThread(function()
            MySQL.query.await("DELETE FROM property_vehicle WHERE property_id = ? AND slot = ?", {
                self.id,
                vehicleData.slot.id
            })
        end)

        TaskWarpPedIntoVehicle(player:ped(), spawnedVehicle, -1)
    end

    if not handleVehicle then
        player:warpOutOfProperty()
    end

    self.players[player.identifier] = nil

    Wait(500)

    player:freeze(false)
    if not settings or settings.transitionIn ~= false then
        player:triggerFunction("FadeIn", 500)
    end
    player:triggerFunction("BusyspinnerOff")

    return true
end

--#endregion

--#region Misc
---Load the linked properties data
function Property:loadLinks()
    local query =
        "SELECT linked_property_id AS property_id FROM property_link WHERE property_id = ? " ..
        "UNION " ..
        "SELECT property_id AS property_id FROM property_link WHERE linked_property_id = ?"

    local queryResult = MySQL.query.await(query, { self.id, self.id })

    self.links = table.map(queryResult, function(row)
        return row.property_id
    end)
end

---Get a player by source
---@param source number
---@return Player?
function Property:getPlayer(source)
    if not self.players or not next(self.players) then
        return
    end

    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    return self.players[playerIdentifier]
end

---Check if player is inside the property
---@param source number
---@return boolean
function Property:isPlayerInside(source)
    return self:getPlayer(source) ~= nil
end

---Save the property
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

---Destroy the property
function Property:destroy()
    self:destroyModel()
    self:destroyProps()
    self:destroyVehicles()
end

---Get the property data
---@return PropertyData
function Property:getData()
    ---@type PropertyData
    local data = {
        id = self.id,
        entranceLocation = self.entranceLocation,
        location = self.location,
        propertyType = self.propertyType,
        address = self.address,
        model = self.model,
        keys = self.keys,
        links = self.links,
        saleData = self.saleData,
        isForSale = self:isForSale(),
        rentData = self.rentData,
        isForRent = self:isForRent(),
    }
    return data
end

---Get the players outside the property
---@return table
function Property:getOutsidePlayers()
    return GetPlayersNearCoords(self.entranceLocation, Config.inviteRange)
end

---Make the player knock on the door
---@param source number
function Property:knock(source)
    Debug.Log(Format("%s knocked on the door of property %s", Bridge.GetPlayerName(source), self.id))

    for _, player in pairs(self.players) do
        if player.key.permission ~= PERMISSION.VISITOR then
            player:triggerFunction("HelpNotification", locale("notification.property.knock"))
        end
    end
end

---Load the property transition data
function Property:loadTransactions()
    local databaseTransactions = MySQL.query.await(
        "SELECT * FROM property_transaction WHERE property_id = ? AND transaction_type IN ('rental', 'sale') ORDER BY start_date DESC LIMIT 2;",
        { self.id }
    )

    self.rentData = table.findOne(databaseTransactions, function(d)
        return d.transaction_type == "rental"
    end)
    self.saleData = table.findOne(databaseTransactions, function(d)
        return d.transaction_type == "sale"
    end)
end

---@return boolean
function Property:isForSale()
    return self.saleData and not self.saleData.customer or false
end

---@return boolean
function Property:isForRent()
    return self.rentData and not self.rentData.customer or false
end

--#endregion
