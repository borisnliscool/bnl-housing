Property = {}
Property.__index = Property

---@param data table
---@return table
function Property.new(data)
    local instance = setmetatable({}, Property)

    instance.id = data.id
    instance.entranceLocation = data.entranceLocation
    instance.location = data.location
    instance.model = data.model
    instance.propertyType = data.propertyType
    instance.address = data.address
    instance.links = data.links
    instance.key = data.key
    instance.points = {}

    instance.blip = nil

    return instance
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

    if
        markerType == "entrance" and
        self.propertyType == "garage" and
        (cache.vehicle and cache.vehicle ~= 0)
    then
        marker.size = vec3(marker.size.x * marker.vehicleSize, marker.size.y * marker.vehicleSize, marker.size.z)
    end

    return marker
end

---Create the property entrance point
function Property:createEntrancePoint()
    -- todo
    --  when we enter the property, this point
    --  always opens the menu when in walk mode,
    --  which we don't want so we need to add
    --  a check for first enter or something
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
                Bridge.HelpNotification(locale("notification.property.menu", Config.points.entrance.interact.name))

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

    -- todo
    --  check for sale or for rent
    if not self.key then return end

    local blipData = Config.blips[self.propertyType][self.key.permission]
    local blip = AddBlipForCoord(self.entranceLocation.x, self.entranceLocation.y, self.entranceLocation.z)

    SetBlipSprite(blip, blipData.sprite)
    SetBlipColour(blip, blipData.color)
    SetBlipDisplay(blip, blipData.display or 2)
    SetBlipScale(blip, blipData.scale or 1.0)
    SetBlipAsShortRange(blip, blipData.short or false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(
        locale(("blip.property.%s.%s"):format(self.propertyType, self.key.permission))
    )
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
                Bridge.HelpNotification(locale("notification.property.menu", Config.points.entrance.interact.name))

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
    self.points.property:remove()
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
