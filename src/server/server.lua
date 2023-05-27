lib.locale()
Properties = {}

function LoadProperties()
    local databaseProperties = MySQL.query.await("SELECT * FROM properties")
    for _, propertyData in pairs(databaseProperties) do
        Properties[propertyData.id] = Property.new(propertyData)
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