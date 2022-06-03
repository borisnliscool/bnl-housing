local function CurrentProperty(source, args, rawCommand)
    local property = GetPropertyPlayerIsInside(source)

    if (property == nil) then
        Logger.Error("Property not found")
        return
    end

    Logger.Success(property)
end

local function PropertyInfo(source, args, rawCommand)
    local property_id = args[1]

    if (property_id == nil) then
        Logger.Error("No property id specified")
        return
    end

    local property = GetPropertyById(property_id)

    if (property == nil) then
        Logger.Error("Property not found")
        return
    end

    Logger.Success(property)
end

local function PermissionLevel(source, args, rawCommand)
    local property = GetPropertyPlayerIsInside(source)

    if (property == nil) then
        Logger.Error("You're not in any property")
        return
    end

    local permissionLevel = GetPlayerPropertyPermissionLevel(source, property)

    if (permissionLevel == nil) then
        Logger.Error("Could not find permisson level")
        return
    end

    Logger.Success(permissionLevel)
end

local function RelativeCoord(source, args, rawCommand)
    local property = GetPropertyPlayerIsInside(source)

    if (property == nil) then
        Logger.Error("You're not in any property")
        return
    end

    local entrance = JsonCoordToVector3(property.entrance) - lowerBy
    local ped = GetPlayerPed(source)
    local pedCoord = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)

    Logger.Success("Coord", entrance - pedCoord, "Heading", pedHeading)
end

local function Enter(source, args, rawCommand)
    local property_id = args[1]

    if (property_id == nil) then
        Logger.Error("No property id specified")
        return
    end

    local property = GetPropertyById(property_id)

    if (property == nil) then
        Logger.Error("Property not found")
        return
    end

    local identifier = GetIdentifier(source)
    local playerPermissionLevel = "owner"

    PlayerEnterProperty(property, {
        identifier = identifier,
        serverId = source,
        name = PlayerName(source),
        permissionLevel = playerPermissionLevel,
    })

    TriggerClientEvent("bnl-housing:client:handleEnter", source, {
        property = property,
        permissionLevel = playerPermissionLevel,
        withVehicle = false
    })
    
    CreateThread(function()
        Wait(1000)
        SpawnPropertyVehicles(property)
    end)
end

RegisterCommand("housing", function(source, a, rawCommand)
    if (source ~= 0) then
        if (not IsPlayerAceAllowed(source, 'bnl-housing:admin')) then
            TriggerClientEvent('bnl-housing:client:notify', source, {
                title = locale('property'),
                description = locale('no_permission'),
                status = 'error',
            })
            return
        end
    end

    local cmd = a[1]
    local args = {}
    for i = 2, #a do
        table.insert(args, a[i])
    end

    if (cmd == 'current') then
        CurrentProperty(source, args, rawCommand)
    elseif (cmd == 'property') then
        PropertyInfo(source, args, rawCommand)
    elseif (cmd == 'permission') then
        PermissionLevel(source, args, rawCommand)
    elseif (cmd == 'coord') then
        RelativeCoord(source, args, rawCommand)
    elseif (cmd == 'enter') then
        Enter(source, args, rawCommand)
    else
        Logger.Error("Invalid command")
    end
end)