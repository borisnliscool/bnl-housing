lib.locale()
Properties = {}

function CreatePropertyPoint(data)
    local point = lib.points.new({
        coords = data.entranceLocation,
        distance = Config.points.entrance.viewDistance,
        property_id = data.id
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
            Bridge.Notify(locale("notification.property.menu", Config.points.entrance.interact.name))

            if IsControlJustReleased(Config.points.entrance.interact.padIndex, Config.points.entrance.interact.control) then
                local entranceMenu = Menus.entrance(self)
                lib.registerMenu(entranceMenu)
                lib.showMenu(entranceMenu.id)
            end
        end
    end

    return point
end

function CreatePropertyBlip(data)
    -- todo
    -- check for sale or for rent
    if not data.key then return end

    local blipData = Config.blips[data.propertyType][data.key.permission]
    local blip = AddBlipForCoord(data.entranceLocation.x, data.entranceLocation.y, data.entranceLocation.z)

    SetBlipSprite(blip, blipData.sprite)
    SetBlipColour(blip, blipData.color)
    SetBlipDisplay(blip, blipData.display or 2)
    SetBlipScale(blip, blipData.scale or 1.0)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(
        locale(("blip.property.%s.%s"):format(data.propertyType, data.key.permission))
    )
    EndTextCommandSetBlipName(blip)

    return blip
end

function SetupProperties()
    for _, property in pairs(Properties) do
        property.point:remove()
    end

    Properties = table.map(
        lib.callback.await("bnl-housing:server:getProperties"),
        function(value)
            return {
                point = CreatePropertyPoint(value),
                blip = CreatePropertyBlip(value)
            }
        end)
end

CreateThread(function()
    Wait(500)
    SetupProperties()
end)
