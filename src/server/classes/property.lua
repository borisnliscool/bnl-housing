Property = {}
Property.__index = Property

-- todo
--  create a Property.new function that creates
--  a new property in the db and returns that
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

    SetRoutingBucketPopulationEnabled(instance.bucketId, false)

    CreateThread(function()
        instance:loadProps()
        instance:loadKeys()
        instance:loadLinks()
        instance:loadVehicleData()
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
function Property:loadKeys()
    local databaseKeys = MySQL.query.await("SELECT * FROM property_key WHERE property_id = ?", { self.id })
    self.keys = databaseKeys
end

---@param source number
function Property:getPlayerKey(source)
    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    local foundKey = table.findOne(self.keys, function(key)
        return key.player == playerIdentifier
    end)
    if foundKey then return foundKey end

    return {
        property_id = self.id,
        permission = Permission.VISITOR,
        player = playerIdentifier,
    }
end

---@param source number
function Property:givePlayerKey(source)
    -- check if the player already has a key
    if self:getPlayerKey(source).permission ~= Permission.VISITOR then
        return
    end

    local key = {
        property_id = self.id,
        player = Bridge.GetPlayerIdentifier(source),
        permission = Permission.MEMBER
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

---@param keyId number
function Property:removePlayerKey(keyId)
    -- if the player has no key, there's nothing to remove
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

function Property:spawnVehicle(data)
    local coords = self.location + vec3(data.slot.location.x, data.slot.location.y, data.slot.location.z)
    local vehicle = CreateVehicle(data.props.model, coords.x, coords.y, coords.z, data.slot.location.w, true, false)

    while not DoesEntityExist(vehicle) do
        Wait(10)
    end

    SetEntityRoutingBucket(vehicle, self.bucketId)
    -- todo
    --  make the vehicle invincible / unchangeable

    Entity(vehicle).state["propertyVehicle"] = {
        property = self.id,
        slot = data.slot
    }

    lib.callback.await(
        "bnl-housing:client:setVehicleProps",
        NetworkGetEntityOwner(vehicle),
        NetworkGetNetworkIdFromEntity(vehicle),
        data.props
    )

    return vehicle
end

function Property:spawnVehicles()
    self:destroyVehicles()

    for _, data in pairs(self.vehicles) do
        if not data.slot then goto skip end

        local vehicle = self:spawnVehicle(data)
        data.entity = vehicle

        ::skip::
    end
end

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

function Property:destroyVehicles()
    for _, vehicle in pairs(self.vehicles) do
        DeleteEntity(vehicle.entity)
    end
end

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

---@param source number
function Property:enter(source)
    if self:isPlayerInside(source) then
        return
    end

    local propertyPlayerIsIn = GetPropertyPlayerIsIn(source)
    if propertyPlayerIsIn ~= nil then
        -- todo
        --  make the transition smoother, currently its doing two
        --  transitions and you see the outside for a split second
        propertyPlayerIsIn:exit(source)
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
    player:triggerFunction("FadeOut", Config.entranceTransition)

    Wait(Config.entranceTransition)

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
    self.players[player.identifier] = player

    Wait(Config.entranceTransition)

    player:freeze(false)
    player:triggerFunction("FadeIn", Config.entranceTransition)
    player:triggerFunction("BusyspinnerOff")

    if handleVehicle then
        TaskLeaveVehicle(player:ped(), spawnedVehicle, 0)
    end

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

    player:triggerFunction("StartBusySpinner", "Exiting property...")
    player:triggerFunction("FadeOut", Config.entranceTransition)
    player:freeze(true)

    Wait(Config.entranceTransition)

    player:setBucket(0)
    player:triggerFunction("RemoveInPropertyPoints", self.id)

    -- Handleing vehicle stuff
    local vehicle = GetVehiclePedIsIn(player:ped(), false)
    local isDriver = GetPedInVehicleSeat(vehicle, -1) == player:ped()
    local vehicleState = Entity(vehicle).state["propertyVehicle"]
    local handleVehicle = vehicle and DoesEntityExist(vehicle) and isDriver and vehicleState ~= nil
    local spawnedVehicle = nil

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

    Wait(Config.entranceTransition)

    player:freeze(false)
    player:triggerFunction("FadeIn", Config.entranceTransition)
    player:triggerFunction("BusyspinnerOff")

    return true
end

--#endregion

--#region Misc
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

---@param source number
function Property:getPlayer(source)
    if not self.players or not next(self.players) then
        return
    end

    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    return self.players[playerIdentifier]
end

---@param source number
function Property:isPlayerInside(source)
    return self:getPlayer(source) ~= nil
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

function Property:destroy()
    Debug.Log(Format("Destroying property %s", self.id))
    self:destroyModel()
    self:destroyProps()
    self:destroyVehicles()
end

function Property:getData()
    return {
        id = self.id,
        entranceLocation = self.entranceLocation,
        location = self.location,
        propertyType = self.propertyType,
        address = self.address,
        model = self.model,
        keys = self.keys,
        links = self.links
    }
end

function Property:getOutsidePlayers()
    return GetPlayersNearCoords(self.entranceLocation, Config.inviteRange)
end

---@param source number
function Property:knock(source)
    Debug.Log(Format("%s knocked on the door of property %s", Bridge.GetPlayerName(source), self.id))

    for _, player in pairs(self.players) do
        if player.key.permission ~= Permission.VISITOR then
            player:triggerFunction("HelpNotification", locale("notification.property.knock"))
        end
    end
end

--#endregion