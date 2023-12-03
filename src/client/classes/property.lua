Property = {}
Property.__index = Property

-- todo we might be able to send all the props at once on property entry,
-- this way we don't leak all the props if the player doesn't have access

---@param data table
---@return table
function Property.new(data)
    local instance = setmetatable({}, Property)

    instance.id = data.id
    instance.blip = nil
    instance:setData(data)
    instance:createEntrancePoint()

    return instance
end

---Set property data
---@param data table
function Property:setData(data)
    self.entranceLocation = data.entranceLocation
    self.location = data.location
    self.model = data.model
    self.propertyType = data.propertyType
    self.address = data.address
    self.links = data.links
    self.key = data.key
    self.points = {}
    self.saleData = data.saleData
    ---@type boolean
    self.isForSale = data.isForSale
    self.rentData = data.rentData
    ---@type boolean
    self.isForRent = data.isForRent
    self.props = data.props

    self:createBlip()

    if CurrentProperty and CurrentProperty.id == self.id then
        SendNUIMessage({
            action = "setPlacedProps",
            data = FormatPlacedProps(data.props)
        })
    end
end

---@return vector3
function Property:getLocation()
    self.location = lib.callback.await("bnl-housing:server:property:getLocation", false, self.id)
    return self.location
end

---Get the marker data for a given marker type
---@param markerType string
---@return Marker
function Property:getMarker(markerType)
    local marker = lib.table.deepclone(Config.points[markerType].marker)

    local isVehicleEnterable = self.propertyType == "garage" or self.propertyType == "warehouse"

    if
        markerType == "entrance" and
        isVehicleEnterable and
        (cache.vehicle and cache.vehicle ~= 0)
    then
        marker.size = vec3(marker.size.x * (marker.vehicleSize or 1), marker.size.y * (marker.vehicleSize or 1),
            marker.size.z)
    end

    return marker
end

---Create the property entrance point
function Property:createEntrancePoint()
    local point = lib.points.new({
        coords = self.entranceLocation,
        distance = Config.points.entrance.viewDistance,
        property = self,
    })

    local getMarker = function(type)
        return self:getMarker(type)
    end

    function point:nearby()
        local markerData = getMarker("entrance")

        DrawMarker(
            markerData.type,
            self.coords.x + markerData.offset.x,
            self.coords.y + markerData.offset.y,
            self.coords.z + markerData.offset.z,
            0.0, 0.0, 0.0,
            markerData.rotation.x,
            markerData.rotation.y,
            markerData.rotation.z,
            markerData.size.x,
            markerData.size.y,
            markerData.size.z,
            markerData.color.r,
            markerData.color.g,
            markerData.color.b,
            markerData.color.a,
            markerData.bob,
            markerData.faceCamera,
            ---@diagnostic disable-next-line: param-type-mismatch
            2, false, nil, nil, false
        )

        if self.currentDistance < (markerData.size.x + markerData.size.y) / 2 then
            if Config.interactMode == "walk" and not self.interacted then
                self.interacted = true
                Menus.entrance(self.property)
            elseif Config.interactMode == "keypress" then
                ShowHelpNotification(locale("notification.property.menu", Config.points.entrance.interact.name))

                if IsControlJustReleased(Config.points.entrance.interact.padIndex, Config.points.entrance.interact.control) then
                    self.interacted = true
                    Menus.entrance(self.property)
                end
            end
        elseif self.interacted then
            self.interacted = false
            lib.hideMenu(true)
        end
    end

    self.points.entrance = point
end

---Create/update the property blip
function Property:createBlip()
    if self.blip then
        RemoveBlip(self.blip)
    end

    if not self.key and not self.isForSale and not self.isForRent then return end

    local blipData = Config.blips[self.propertyType][self.key and self.key.permission or "sale"]
    if not blipData then return end

    local blip = AddBlipForCoord(self.entranceLocation.x, self.entranceLocation.y, self.entranceLocation.z)

    SetBlipSprite(blip, blipData.sprite)
    SetBlipColour(blip, blipData.color)
    SetBlipDisplay(blip, blipData.display or 2)
    SetBlipScale(blip, blipData.scale or 1.0)
    SetBlipAsShortRange(blip, blipData.short or false)

    local name = locale(
        ("blip.property.%s.%s"):format(
            self.propertyType,
            self.key and self.key.permission or self.isForSale and TRANSACTION_TYPE.SALE or TRANSACTION_TYPE.RENTAL
        )
    )
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)

    self.blip = blip
end

---Create in property points
function Property:createInPropertyPoints()
    local data = Data.Shells[self.model]

    local point = lib.points.new({
        coords = self:getLocation() + data.entrances.foot,
        distance = Config.points.property.viewDistance,
        property = self
    })

    local getMarker = function(type)
        return self:getMarker(type)
    end

    function point:nearby()
        local markerData = getMarker("property")

        DrawMarker(
            markerData.type,
            self.coords.x + markerData.offset.x,
            self.coords.y + markerData.offset.y,
            self.coords.z + markerData.offset.z,
            0.0, 0.0, 0.0,
            markerData.rotation.x,
            markerData.rotation.y,
            markerData.rotation.z,
            markerData.size.x,
            markerData.size.y,
            markerData.size.z,
            markerData.color.r,
            markerData.color.g,
            markerData.color.b,
            markerData.color.a,
            markerData.bob,
            markerData.faceCamera,
            ---@diagnostic disable-next-line: param-type-mismatch
            2, false, nil, nil, false
        )

        if self.currentDistance < (markerData.size.x + markerData.size.y) / 2 then
            if Config.interactMode == "walk" and not self.interacted then
                self.interacted = true
                Menus.property(self.property)
            elseif Config.interactMode == "keypress" then
                ShowHelpNotification(locale("notification.property.menu", Config.points.entrance.interact.name))

                if IsControlJustReleased(Config.points.entrance.interact.padIndex, Config.points.entrance.interact.control) then
                    self.interacted = true
                    Menus.property(self.property)
                end
            end
        elseif self.interacted then
            self.interacted = false
            lib.hideMenu(true)
        end
    end

    self.points.property = point
end

---Remove all in property points
function Property:removeInPropertyPoints()
    return self.points.property and self.points.property:remove()
end

---Get all the players outside the property
---@return table
function Property:getOutsidePlayers()
    return lib.callback.await("bnl-housing:server:getOutsidePlayers", false, self.id)
end

---Get all the property keys
---@return table
function Property:getKeys()
    return lib.callback.await("bnl-housing:server:property:getKeys", false, self.id)
end

function Property:startSale()
    local input = lib.inputDialog(locale("menu.property.sell"), {
        {
            type = "number",
            label = locale("menu.property.sell.price")
        }
    })

    if not input then return end

    local price = input[1]
    if not price then return end

    local confirmed = lib.alertDialog({
        header   = locale("confirm"),
        content  = locale("menu.property.sell.confirm", self.address.streetName, self.address.buildingNumber, price),
        centered = true,
        cancel   = true
    }) == "confirm"

    if not confirmed then return end

    local success = lib.callback.await("bnl-housing:server:property:sell", false, CurrentProperty.id, price)
    lib.print.debug("Success: ", success)
    -- todo notification
end

function Property:startRental()
    local input = lib.inputDialog(locale("menu.property.rent_out"), {
        {
            type = "number",
            label = locale("menu.property.rent.price_per_week")
        }
    })

    if not input then return end

    local price = input[1]
    if not price then return end

    local confirmed = lib.alertDialog({
        header   = locale("confirm"),
        content  = locale("menu.property.rent.confirm", self.address.streetName, self.address.buildingNumber, price),
        centered = true,
        cancel   = true
    }) == "confirm"

    if not confirmed then return end

    local success = lib.callback.await("bnl-housing:server:property:rentout", false, CurrentProperty.id, price)
    lib.print.debug("Success: ", success)

    -- todo notification
end
