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

lib.callback.register("bnl-housing:server:getProperties", function(source)
    return table.map(Properties, function(property)
        return {
            id = property.id,
            entranceLocation = property.entranceLocation
        }
    end)
end)