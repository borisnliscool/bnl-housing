lib.locale()

---@type table, table | nil
Properties, CurrentProperty = {}, nil

RegisterNetEvent("bnl-housing:on:enterProperty")
RegisterNetEvent("bnl-housing:on:leaveProperty")
RegisterNetEvent("bnl-housing:on:showUI")
RegisterNetEvent("bnl-housing:on:hideUI")

function SetupProperties()
    for _, property in pairs(Properties) do
        property.point:remove()
    end

    Properties = {}

    for _, data in pairs(lib.callback.await("bnl-housing:server:getProperties")) do
        local property = Property.new(data)
        if property then
            Properties[property.id] = property
        end
    end
end

---This function is callable from the server.
---@param propertyId number
function SetupInPropertyPoints(propertyId)
    local property = table.findOne(Properties, function(property)
        return property.id == propertyId
    end)
    if not property then return end

    property:createInPropertyPoints()
end

---This function is callable from the server.
---@param propertyId number
function RemoveInPropertyPoints(propertyId)
    local property = table.findOne(Properties, function(property)
        return property.id == propertyId
    end)
    if not property then return end

    property:removeInPropertyPoints()
end

---This function is callable from the server
---@param propertyId number
---@param propertyData table
function UpdateProperty(propertyId, propertyData)
    if not Properties[propertyId] then
        Properties[propertyId] = Property.new(propertyData)
    end
    return Properties[propertyId]:setData(propertyData)
end

---@param name string
---@param id number
---@return string
function FormatPlayerTag(name, id)
    local options = {
        name = ("#%s"):format(name),
        id = ("#%s"):format(id),
        both = ("[#%s] %s"):format(id, name),
    }
    return options[Config.playerTag]
end

---Show a help notification to the player
---@param message string
---@param time? number
function ShowHelpNotification(message, time)
    AddTextEntry("bnl-housing:helpMessage", message)
    BeginTextCommandDisplayHelp("bnl-housing:helpMessage")
    EndTextCommandDisplayHelp(0, false, true, (time ~= nil and time or 5) * 1000)
end

---This function is callable from the server.
---@param text string
function StartBusySpinner(text)
    BeginTextCommandBusyspinnerOn('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandBusyspinnerOn(5)
end

AddEventHandler("bnl-housing:on:enterProperty", function(propertyId, _)
    CurrentProperty = table.findOne(Properties, function(property)
        return property.id == propertyId
    end)
end)

AddEventHandler("bnl-housing:on:leaveProperty", function(_, _)
    ExitEditor(false)
    CurrentProperty = false
end)

Bridge.onReady(SetupProperties)


-- todo move to commands or something
RegisterCommand("housing", function(source, args, rawCommand)
    ShowUI("adminMenu")
end, false)
