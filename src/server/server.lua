lib.locale()
Properties = {}

function LoadProperties()
    local databaseProperties = MySQL.query.await("SELECT * FROM properties")
    for _, propertyData in pairs(databaseProperties) do
        Properties[propertyData.id] = Property.new(propertyData)
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

CreateThread(function()
    Wait(10)
    LoadProperties()
end)

-- todo: remove this temp command
RegisterCommand("save", function(source, args, rawCommand)
    for key, value in pairs(Properties) do
        value:save()
    end
end, false)

RegisterCommand("enter", function(source, args, rawCommand)
    local property = GetPropertyById(args[1] or 1)
    property:enter(source)
end, false)

RegisterCommand("exit", function(source, args, rawCommand)
    local property = GetPropertyById(args[1] or 1)
    property:exit(source)
end, false)

RegisterCommand("bucket", function(source, args, rawCommand)
    SetPlayerRoutingBucket(source, args[1] or 0)
end, false)