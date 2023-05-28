Property = {}
Property.__index = Property

function Property.new(data)
    local instance = setmetatable({}, Property)

    instance.id = data.id
    instance.entranceLocation = data.entranceLocation
    instance.location = data.location
    instance.model = data.model
    instance.propertyType = data.propertyType
    instance.key = data.key
    instance.points = {}

    instance.blip = nil

    return instance
end

function Property:getLocation()
    self.location = lib.callback.await(cache.resource .. ":server:property:getLocation", false, self.id)
    return self.location
end

function Property:createEntrancePoint()
    -- todo
    -- when we enter the property, this point
    -- always opens the menu when in walk mode, 
    -- which we don't want so we need to add
    -- a check for first enter or something
    local point = lib.points.new({
        coords = self.entranceLocation,
        distance = Config.points.entrance.viewDistance,
        property = self,
    })

    local markerData = Config.points.entrance.marker

    function point:nearby()
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
                Bridge.Notify(locale("notification.property.menu", Config.points.entrance.interact.name))

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

function Property:createBlip()
    if self.blip then
        RemoveBlip(self.blip)
    end

    -- todo
    -- check for sale or for rent
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

function Property:createInPropertyPoints()
    local data = Data.Shells[self.model]

    local point = lib.points.new({
        coords = self:getLocation() + data.entrances.foot,
        distance = Config.points.property.viewDistance,
        property = self
    })

    local markerData = Config.points.property.marker

    function point:nearby()
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
                Bridge.Notify(locale("notification.property.menu", Config.points.entrance.interact.name))

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

function Property:removeInPropertyPoints()
    self.points.property:remove()
end
