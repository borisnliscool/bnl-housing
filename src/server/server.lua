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

Bridge.onReady(LoadProperties)

exports("GetPropertyById", GetPropertyById)
exports("GetPropertyPlayerIsIn", GetPropertyPlayerIsIn)
