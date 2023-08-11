-- todo: temp
RegisterCommand("save", function(source, args, rawCommand)
    for key, value in pairs(Properties) do
        value:save()
    end
end, false)

RegisterCommand("enter", function(source, args, rawCommand)
    local property = GetPropertyById(tonumber(args[1]) or 1)
    return property and property:enter(source)
end, false)

RegisterCommand("exit", function(source, args, rawCommand)
    local property = GetPropertyPlayerIsIn(source)
    return property and property:exit(source)
end, false)

RegisterCommand("bucket", function(source, args, rawCommand)
    SetPlayerRoutingBucket(source, tonumber(args[1] or "0") --[[@as number]])
end, false)

RegisterCommand("relative", function(source, args, rawCommand)
    local property = GetPropertyPlayerIsIn(source) or GetPropertyById(tonumber(args[1]) or 1)
    if not property then return end
    local coords = GetEntityCoords(GetPlayerPed(source))

    Debug.Log(coords - property.location)
    ClientFunctions.SetClipboard(source, tostring(coords - property.location))
end, false)

RegisterCommand("knock", function(source, args, rawCommand)
    local property = GetPropertyPlayerIsIn(source) or GetPropertyById(tonumber(args[1]) or 1)
    return property and property:knock(source)
end, false)

RegisterCommand("housing:insert", function(source, args, rawCommand)
    local data = json.decode(args[1])
    if not data then return end

    local property = GetPropertyPlayerIsIn(source)
    if not property then return end

    for _, prop in pairs(data) do
        MySQL.query.await("INSERT INTO property_prop (property_id, model, location, rotation) VALUES (?, ?, ?, ?)", {
            property.id,
            prop.model,
            json.encode(prop.coords),
            json.encode(prop.rotation),
        })
    end
end, false)

RegisterCommand("vehicle", function(source, args, rawCommand)
    Debug.Log(
        GetPlayersInVehicle(
            GetVehiclePedIsIn(GetPlayerPed(source), false)
        )
    )
end, false)
