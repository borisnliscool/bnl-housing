Property = {}
Property.__index = Property

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

---@param data NewPropertyData
function Property.new(data)
    -- todo sale or rental data handling
    -- todo initial owner handling

    local newProperty = DB.createProperty(
        data.model, data.location, data.propertyType, data.zipcode, data.streetName, data.buildingNumber
    )

    if not newProperty.insertId then
        return error("Could not create new property")
    end

    local propertyData = DB.getProperty(newProperty.insertId)
    if not propertyData then
        return error("Could not find property")
    end

    local property = Property.load(propertyData)
    Properties[newProperty.insertId] = property
    property:triggerUpdate()

    return property
end

--#region Model

---Destroys the property shell entity
function Property:destroyModel()
    if DoesEntityExist(self.entity) then
        DeleteEntity(self.entity)
    end
    self.entity = nil
end

---Spawns the property shell entity
function Property:spawnModel()
    self:destroyModel()

    local entity = CreateObject(
        self.model,
        self.entranceLocation.x,
        self.entranceLocation.y,
        1500.0,
        true,
        true,
        false
    )

    local start = GetGameTimer()

    while not DoesEntityExist(entity) do
        Wait(10)

        if GetGameTimer() - start > 10000 then
            Debug.Error(Format("Timed out. Failed to load shell %s.", self.model))
            return
        end
    end

    SetEntityRoutingBucket(entity, self.bucketId)
    Wait(100)
    FreezeEntityPosition(entity, true)

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

    local databaseProps = DB.getPropertyProps(self.id)
    self.props = table.map(databaseProps, function(propData)
        return Prop.new(propData, self)
    end)
end

-- todo
--  currently there's no way to update a prop,
--  so we just delete it and add a new one when
--  we want to update it.

---@param propData table
function Property:addProp(propData)
    local modelData = GetPropFromModel(propData.model)

    propData.location = propData.location - self.location -
        (modelData and modelData.offset and vec3(modelData.offset.x, modelData.offset.y, modelData.offset.z) or vec3(0, 0, 0))

    local ret = DB.insertPropertyProp(
        self.id,
        propData.model,
        propData.location,
        propData.rotation
    )

    local prop = Prop.new({
        id = ret.insertId,
        model = propData.model,
        location = propData.location,
        rotation = propData.rotation,
        metadata = {}
    }, self)

    table.insert(self.props, prop)
    prop:spawn()

    self:triggerUpdate(table.map(self.players, function(player)
        return player.source
    end))
end

---@param propId number
function Property:removeProp(propId)
    local prop, key = table.findOne(self.props, function(_prop)
        return _prop.id == propId
    end)
    if not prop or not key then return end

    DB.deletePropertyProp(propId)

    prop:destroy()
    table.remove(self.props, key)

    self:triggerUpdate(table.map(self.players, function(player)
        return player.source
    end))
end

--#endregion

--#region Keys

---Load the property keys
function Property:loadKeys()
    local databaseKeys = DB.getPropertyKeys(self.id)
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
---@param permission Permissions
---@param update? boolean
function Property:givePlayerKey(source, permission, update)
    if not permission then
        permission = PERMISSION.MEMBER
    end
    if update == nil then
        update = true
    end

    -- check if the player already has a key
    local playerKey = self:getPlayerKey(source)
    if playerKey.permission ~= PERMISSION.VISITOR then
        self:removePlayerKey(playerKey.id)
        return
    end

    ---@type Key
    ---@diagnostic disable-next-line: missing-fields
    local key = {
        property_id = self.id,
        player = Bridge.GetPlayerIdentifier(source),
        permission = permission
    }

    key.id = DB.insertPropertyKey(key.property_id, key.player, key.permission)

    table.insert(self.keys, key)
    Debug.Log(Format("Gave key to %s for property %s", key.player, self.id))
    lib.logger(player, ("gave key to %s for property %s"):format(key.player, self.id))

    if update then
        self:triggerUpdate(source)
    end
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

    DB.removePropertyKey(key.id)
    table.remove(self.keys, id)

    Debug.Log(Format("Removed key %s from property %s", key.id, self.id))
    lib.logger(player, ("removed key %s from property %s"):format(key.id, self.id))

    self:triggerUpdate()
end

---Function to remove all keys from property
---@param update? boolean
function Property:removeAllKeys(update)
    if update == nil then
        update = true
    end

    DB.removePropertyKeys(self.id)
    self.keys = {}

    if update then
        self:triggerUpdate()
    end
end

--#endregion

--#region Vehicles

---Load the data for all the vehicles
function Property:loadVehicleData()
    self.vehicles = table.map(
        DB.getPropertyVehicles(self.id),
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

    Wait(100)

    Entity(vehicle).state["propertyVehicle"] = {
        property = self.id,
        slot = data.slot
    }
    Entity(vehicle).state["undriveable"] = true

    SetVehicleProps(vehicle, data.props)

    Wait(100)

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

    Wait(100)

    return vehicle
end

---Destroy all the vehicles in the property
function Property:destroyVehicles()
    for _, vehicle in pairs(self.vehicles) do
        if DoesEntityExist(vehicle.entity) then
            DeleteEntity(vehicle.entity)
        end
        vehicle.entity = nil
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
        propertyPlayerIsIn:exit(source, {
            transitionIn = false,
        })
    end

    local player = Player.new(source, self)

    local vehicle = player:vehicle()
    local isDriver = GetPedInVehicleSeat(vehicle, -1) == player:ped()
    local handleVehicle = vehicle and DoesEntityExist(vehicle)
    local spawnedVehicle, vehicleProps = nil, nil

    if handleVehicle and isDriver then
        if not self.shellData.vehicleSlots or #self.shellData.vehicleSlots == #self.vehicles then
            -- this garage is full
            player:triggerFunction("Notification", locale("notification.property.noVehicleSpace"), "error")
            return false
        end

        vehicleProps = GetVehicleProps(vehicle)

        -- I don't know why this is sleeping here, but it won't work without.
        CreateThread(function()
            Wait(500)

            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end)
    end

    self:triggerUpdate(source)

    player:triggerFunction("StartBusySpinner", "Loading property...")
    player:triggerFunction("FadeOut", 500)

    Wait(500)

    player:freeze(true)
    player:setBucket(self.bucketId)

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

    if handleVehicle and isDriver then
        local slot = self:getFirstFreeVehicleSlot()
        if not slot then
            Debug.Error("Could not find a slot for the vehicle, this shouldn't happen!")
            return false
        end

        local vehicleData = {
            props = vehicleProps,
            slot = slot,
        }

        local _, err = pcall(function()
            DB.insertPropertyVehicle(self.id, slot.id, vehicleProps or {})
        end)

        if err then
            Debug.Error(err)
            goto skipVehicleSpawning
        end

        spawnedVehicle = self:spawnVehicle(vehicleData)
        vehicleData.entity = spawnedVehicle

        table.insert(self.vehicles, vehicleData)

        ::skipVehicleSpawning::
    end

    if handleVehicle or (settings and settings.isPassenger) then
        TaskWarpPedIntoVehicle(player:ped(),
            spawnedVehicle --[[@as Entity]],
            -1
        )
    else
        player:warpIntoProperty()
    end

    player:triggerFunction("SetupInPropertyPoints", self.id)

    self.players[player.identifier] = player

    TriggerEvent("bnl-housing:on:enterProperty", source, self.id, handleVehicle and spawnedVehicle)
    TriggerClientEvent("bnl-housing:on:enterProperty", source, self.id, handleVehicle and spawnedVehicle)
    lib.logger(player,
        ("player %s entered property %s %s"):format(source, self.id,
            handleVehicle and spawnedVehicle and "with a vehicle" or "on foot")
    )

    Wait(500)

    player:freeze(false)
    if not settings or settings.transitionIn ~= false then
        player:triggerFunction("FadeIn", 500)
    end
    player:triggerFunction("BusyspinnerOff")

    if handleVehicle then
        TaskLeaveVehicle(player:ped(), spawnedVehicle --[[@as Entity]], 0)
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
    local handleVehicle = vehicle and DoesEntityExist(vehicle) and vehicleState ~= nil
    local spawnedVehicle = nil

    player:triggerFunction("RemoveInPropertyPoints", self.id)

    if handleVehicle and isDriver then
        local vehicleData, index = table.findOne(self.vehicles, function(veh)
            return vehicleState.slot.id == veh.slot.id
        end)
        table.remove(self.vehicles, index)

        if vehicleData == nil then
            Debug.Error("Couldn't find vehicleData for vehicle", vehicle)
            return false
        end

        DeleteEntity(vehicle)

        player:setBucket(0)
        spawnedVehicle = self:spawnOutsideVehicle(vehicleData.props)

        TaskWarpPedIntoVehicle(player:ped(), spawnedVehicle --[[@as Entity]], -1)

        -- Hack to make setting the properties work, because otherwise,
        -- for some reason, it fucks itself
        CreateThread(function()
            local ped = player:ped()
            while GetPedInVehicleSeat(spawnedVehicle, -1) ~= ped do
                Wait(100)
            end
            Wait(100)

            SetVehicleProps(spawnedVehicle --[[@as Entity]], vehicleData.props)
        end)

        CreateThread(function()
            DB.removePropertyVehicle(self.id, vehicleData.slot.id)
        end)
    end

    if not handleVehicle then
        player:setBucket(0)
        player:warpOutOfProperty()
    end

    self.players[player.identifier] = nil

    TriggerEvent("bnl-housing:on:leaveProperty", source, self.id, handleVehicle and spawnedVehicle)
    TriggerClientEvent("bnl-housing:on:leaveProperty", source, self.id, handleVehicle and spawnedVehicle)
    lib.logger(player,
        ("player %s left property %s %s"):format(source, self.id,
            handleVehicle and spawnedVehicle and "with a vehicle" or "on foot")
    )

    Wait(500)

    player:freeze(false)
    if not settings or settings.transitionIn ~= false then
        player:triggerFunction("FadeIn", 500)
    end
    player:triggerFunction("BusyspinnerOff")

    if Config.unloadOnEmpty and table.count(self.players) == 0 then
        self:destroy()
    end

    return true
end

--#endregion

--#region Misc

---Load the linked properties data
function Property:loadLinks()
    local propertyLinks = DB.getPropertyLinks(self.id)

    self.links = table.map(propertyLinks, function(row)
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
    -- todo do this in one thingy
    if self.props and #self.props > 0 then
        for _, prop in pairs(self.props) do
            DB.updatePropertyProp(prop.metadata, prop.id)
        end
    end
end

---Destroy the property
function Property:destroy()
    self.isSpawning = false
    self.isSpawned = false
    self.isSpawningVehicles = false
    self.vehiclesSpawned = false

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
        props = table.map(self.props, function(prop)
            return prop:getData()
        end)
    }
    return data
end

---Get the players outside the property
---@return table
function Property:getOutsidePlayers()
    return GetPlayersNearCoords(
        vector3(self.entranceLocation.x, self.entranceLocation.y, self.entranceLocation.z),
        Config.inviteRange
    )
end

---Make the player knock on the door
---@param source number
function Property:knock(source)
    Debug.Log(Format("%s knocked on the door of property %s", Bridge.GetPlayerName(source), self.id))
    lib.logger(player,
        ("player %s knocked on the door of property %s"):format(source, self.id)
    )

    for _, player in pairs(self.players) do
        if player.key.permission ~= PERMISSION.VISITOR then
            player:triggerFunction("HelpNotification", locale("notification.property.knock"))
        end
    end
end

---Load the property transition data
function Property:loadTransactions()
    local databaseTransactions = DB.getPropertyTransactions(self.id)

    self.rentData = table.findOne(databaseTransactions, function(d)
        return d.transaction_type == TRANSACTION_TYPE.RENTAL
    end)
    self.saleData = table.findOne(databaseTransactions, function(d)
        return d.transaction_type == TRANSACTION_TYPE.SALE
    end)
end

---@return boolean
function Property:isForSale()
    return self.saleData and self.saleData.status == COMPLETION_STATUS.UNCOMPLETED or false
end

---@return boolean
function Property:isForRent()
    return self.rentData and self.rentData.status == COMPLETION_STATUS.UNCOMPLETED or false
end

---@param source number
function Property:buy(source)
    if not self:isForSale() then return end

    local price = self.saleData.price
    if Bridge.GetMoney(source) < price then
        ClientFunctions.Notification(source, locale("notification.buy.noMoney"), "error")
        return
    end

    Bridge.RemoveMoney(source, price)
    self:removeAllKeys(false)
    self:givePlayerKey(source, PERMISSION.OWNER, false)

    ClientFunctions.Notification(source, locale(
        "notification.buy.success", self.address.streetName, self.address.buildingNumber, price
    ), "success")

    local playerIdentifier = Bridge.GetPlayerIdentifier(source)

    DB.insertPropertyPayment(playerIdentifier, self.id, price, TRANSACTION_TYPE.SALE)
    DB.updatePropertyTransaction(playerIdentifier, COMPLETION_STATUS.COMPLETED, self.saleData.id)

    TriggerEvent("bnl-housing:on:buyProperty", source, self.id, price)
    lib.logger(player, ("player %s bought property %s for %s"):format(source, self.id, price))

    if self:isForRent() then
        DB.deletePropertyTransaction(self.rentData.id)
    end

    self:loadTransactions()
    self:triggerUpdate()
end

---@param source number
function Property:rent(source)
    -- todo
    --  remove any other renter payments
    --  and maybe key owners?

    if not self:isForRent() then return end

    local price = self.rentData.price
    if Bridge.GetMoney(source) < price then
        ClientFunctions.Notification(source, locale("notification.rent.noMoney"), "error")
        return
    end

    local key = self:getPlayerKey(source)
    if key.permission == PERMISSION.OWNER then
        ClientFunctions.Notification(source, locale("notification.rent.owner"), "error")
        return
    end

    Bridge.RemoveMoney(source, price)
    self:givePlayerKey(source, PERMISSION.RENTER, false)

    ClientFunctions.Notification(source, locale(
        "notification.rent.success", self.address.streetName, self.address.buildingNumber, price
    ), "success")

    local playerIdentifier = Bridge.GetPlayerIdentifier(source)
    local paymentInterval = GenerateRentCronJob()

    DB.insertPropertyPayment(playerIdentifier, self.id, price, TRANSACTION_TYPE.RENTAL, paymentInterval)
    DB.updatePropertyTransaction(playerIdentifier, COMPLETION_STATUS.COMPLETED, self.rentData.id)

    TriggerEvent("bnl-housing:on:rentProperty", source, self.id, price)
    lib.logger(player, ("player %s rented property %s for %s"):format(source, self.id, price))

    self:loadTransactions()
    self:triggerUpdate()
end

---@param price number
function Property:markForSale(price)
    if self:isForSale() then return end

    DB.insertPropertyTransaction(self.id, price, TRANSACTION_TYPE.SALE)

    self:loadTransactions()
    self:triggerUpdate()

    lib.logger(player,
        ("player %s marked property %s for sale for %s"):format(source, self.id, price)
    )

    return true
end

---@param price number
function Property:markForRent(price)
    if self:isForRent() then return end

    DB.insertPropertyTransaction(self.id, price, TRANSACTION_TYPE.RENTAL)

    self:loadTransactions()
    self:triggerUpdate()

    lib.logger(player,
        ("player %s marked property %s for rent for %s"):format(source, self.id, price)
    )

    return true
end

---Update the property on all clients or the specified source
---@param source number | table | nil
function Property:triggerUpdate(source)
    local data = self:getData()
    data.keys = nil

    data.props = table.map(data.props, function(prop)
        prop.metadata = prop.metadata?.public or {}
        return prop
    end)

    local function SendToPlayer(_source)
        data.key = self:getPlayerKey(_source)
        ClientFunctions.UpdateProperty(_source, self.id, data)
    end

    if source and type(source) == "number" then
        return SendToPlayer(source)
    end

    local players = (source and type(source) == "table") and source or Bridge.GetAllPlayers()
    for _, _source in pairs(players) do
        CreateThread(function()
            SendToPlayer(_source)
        end)
    end
end

--#endregion
