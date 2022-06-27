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

local codes = {}
local function NewProperty(source, args, rawCommand)
    local code = string.random(16)
    codes[source] = code
    TriggerClientEvent('bnl-housing:client:showCreatePropertyPromt', source, code)
end

RegisterNetEvent("bnl-housing:server:createProperty", function(data, code)
    if (not codes[source] == code) then
        Logger.Error('Incorrect code.')
        return
    end

    local shellId = data[1]
    if (not shellId) then return end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local entrance = vector4(coords, heading)
    if (not entrance) then return end

    local owner = GetIdentifier(source)
    if (not owner) then return end

    MySQL.insert('INSERT INTO `bnl_housing` (`owner`, `entrance`, `shell_id`) VALUES (?, ?, ?)', { owner, json.encode(entrance), shellId }, function(id)
        print(id)
    end)
end)

local function Help(source, args, rawCommand)
    Logger.Success("Here's a list of all commands: ", {
        {cmd = "housing current", desc = "Shows the current property you're in"},
        {cmd = "housing property <property_id>", desc = "Shows the info about the current property"},
        {cmd = "housing permission", desc = "Shows your permission level in the current property"},
        {cmd = "housing coord", desc = "Shows your relative coord in the property"},
        {cmd = "housing enter <property_id>", desc = "Enters given the property with owner permissions"},
        {cmd = "housing new", desc = "Prompt to create a new property"},
        {cmd = "housing help", desc = "Shows this help message"},
    })
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
    elseif (cmd == 'new') then
        NewProperty(source, args, rawCommand)
    elseif (cmd == 'help') then
        Help(source, args, rawCommand)
    else
        Logger.Error("Unknown command")
    end
end)