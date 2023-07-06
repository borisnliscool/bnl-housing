lib.locale()
Properties = {}

RegisterNetEvent("bnl-housing:on:enterProperty")
RegisterNetEvent("bnl-housing:on:leaveProperty")

---Load all properties
local function LoadProperties()
    local databaseProperties = MySQL.query.await("SELECT * FROM properties")
    for _, propertyData in pairs(databaseProperties) do
        Properties[propertyData.id] = Property.load(propertyData)
    end

    Wait(100)
    for _, source in pairs(Bridge.GetAllPlayers()) do
        ClientFunctions.Notification(source, locale("notification.ready"),  "success")
    end
end

---Get a property by it's id
---@param id number
---@return Property?
function GetPropertyById(id)
    return Properties[id]
end

---Get the property a player is in
---@param source number
---@return Property?
function GetPropertyPlayerIsIn(source)
    for _, property in pairs(Properties) do
        if property:isPlayerInside(source) then
            return property
        end
    end
end

---@param coords vector3
---@param radius number
function GetPlayersNearCoords(coords, radius)
    local players = {}
    for _, player in pairs(Bridge.GetAllPlayers()) do
        local playerCoords = GetEntityCoords(GetPlayerPed(player))
        local distance = #(coords - playerCoords)
        if distance <= radius then
            table.insert(players, player)
        end
    end
    return players
end

---Function that execute when a player loads
---@param player number
local function onPlayerLoad(player)
    local playerIdentifier = Bridge.GetPlayerIdentifier(player)
    Debug.Log(Format("Loading player %s", Bridge.GetPlayerName(player)))

    local data = MySQL.single.await(
        "SELECT property_id FROM property_player WHERE player = ?",
        { playerIdentifier }
    )
    if not data or not data.property_id then return end
    local propertyId = data.property_id

    local property = GetPropertyById(propertyId)
    if not property then return end

    Wait(250)

    if property:enter(player) then
        Debug.Log(Format("Loaded player %s in property %s", Bridge.GetPlayerName(player), propertyId))
        MySQL.query.await("DELETE FROM property_player WHERE player = ?", { playerIdentifier })
        return
    end

    Debug.Error(Format("Failed to make %s enter property %s", Bridge.GetPlayerName(player), propertyId))
end

---Function that execute when a player unloads
---@param player number
local function onPlayerUnload(player)
    local property = GetPropertyPlayerIsIn(player)
    if not property then return end

    local playerIdentifier = Bridge.GetPlayerIdentifier(player)
    property.players[playerIdentifier] = nil

    MySQL.insert.await(
        "INSERT INTO property_player (property_id, player) VALUES (?, ?)",
        { property.id, playerIdentifier }
    )
end

Bridge.onReady(LoadProperties)
Bridge.onPlayerLoad(onPlayerLoad)
Bridge.onPlayerUnload(onPlayerUnload)
