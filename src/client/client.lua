lib.locale()
Properties = {}

function Notify(message, timeSeconds)
    AddTextEntry(message, message)
    BeginTextCommandDisplayHelp(message)
    EndTextCommandDisplayHelp(0, false, true, (timeSeconds or 10) * 1000)
end

function CreatePropertyPoint(data)
    local point = lib.points.new({
        coords = data.entranceLocation,
        distance = Config.entrance.viewDistance,
        property_id = data.id
    })

    local markerData = Config.entrance.marker
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
            Notify(locale("property.enter", Config.entrance.interact.name))

            if IsControlJustReleased(Config.entrance.interact.padIndex, Config.entrance.interact.control) then
                -- todo
                -- logic for entering the property

                print("enter property with id:", self.property_id)
            end
        end
    end

    return point
end

function SetupProperties()
    for _, point in pairs(Properties) do
        point:remove()
    end

    Properties = table.map(
        lib.callback.await("bnl-housing:server:getProperties"),
        function(value)
            return CreatePropertyPoint(value)
        end)
end

CreateThread(function()
    Wait(500)
    SetupProperties()
end)
