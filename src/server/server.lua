lib.locale()
Properties = {}

function LoadProperties()
    local databaseProperties = MySQL.query.await("SELECT * FROM properties")
    for _, propertyData in pairs(databaseProperties) do
        Properties[propertyData.id] = Property.load(propertyData)
    end
end

---@param id number
function GetPropertyById(id)
    return Properties[id]
end

---@param source number
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
