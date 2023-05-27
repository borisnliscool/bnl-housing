lib.locale()
Properties = {}

function LoadProperties()
    local databaseProperties = MySQL.query.await("SELECT * FROM properties")
    for _, propertyData in pairs(databaseProperties) do
        Properties[propertyData.id] = Property.load(propertyData)
    end
end

function GetPropertyById(id)
    return Properties[id]
end

function GetPropertyPlayerIsIn(source)
    for _, property in pairs(Properties) do
        if property:isPlayerInside(source) then
            return property
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end

    for _, property in pairs(Properties) do
        for _, player in pairs(property.players) do
            player:warpOutOfProperty()
        end
        property:destroy()
    end
end)

Bridge.onReady(LoadProperties)

-- todo: remove these temp command
RegisterCommand("save", function(source, args, rawCommand)
    for key, value in pairs(Properties) do
        value:save()
    end
end, false)

RegisterCommand("enter", function(source, args, rawCommand)
    local property = GetPropertyById(tonumber(args[1]) or 1)
    property:enter(source)
end, false)

RegisterCommand("exit", function(source, args, rawCommand)
    local property = GetPropertyPlayerIsIn(source)
    property:exit(source)
end, false)

RegisterCommand("bucket", function(source, args, rawCommand)
    ---@diagnostic disable-next-line: param-type-mismatch
    SetPlayerRoutingBucket(source, tonumber(args[1] or "0"))
end, false)

RegisterCommand("relative", function(source, args, rawCommand)
    local property = GetPropertyPlayerIsIn(source) or GetPropertyById(tonumber(args[1]) or 1)
    if not property then return end
    local coords = GetEntityCoords(GetPlayerPed(source))

    Debug.Log(coords - property.location)
    TriggerClientEvent("ox_lib:setClipboard", source, tostring(coords - property.location))
end, false)
