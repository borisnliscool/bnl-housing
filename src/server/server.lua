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
    local playerIdentifier = Bridge.GetPlayerIdentifier(source)

    return table.map(Properties, function(property)
        return {
            id = property.id,
            entranceLocation = property.entranceLocation,
            propertyType = property.propertyType,
            key = table.findOne(property.keys, function(key)
                return key.player == playerIdentifier
            end)
        }
    end)
end)
