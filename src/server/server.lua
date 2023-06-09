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

local function onPlayerLoad(player)
    local playerIdentifier = Bridge.GetPlayerIdentifier(player)
    Debug.Log(Format("Loading player %s", Bridge.GetPlayerName(player)))

    local propertyId = MySQL.single.await(
        "SELECT property_id FROM property_player WHERE player = ?",
        { playerIdentifier }
    ).property_id
    if not propertyId then return end

    local property = GetPropertyById(propertyId)
    if not property then return end

    Wait(250)

    if property:enter(player, {
        disableWarp = true
    }) then
        Debug.Log(Format("Loaded player %s in property %s", Bridge.GetPlayerName(player), propertyId))
        MySQL.query.await("DELETE FROM property_player WHERE player = ?", { playerIdentifier })
        return
    end

    Debug.Error("Failed to make %s enter property %s", Bridge.GetPlayerName(player), propertyId)
end

local function onPlayerUnload(player)
    local property = GetPropertyPlayerIsIn(player)
    if not property then return end

    Bridge.SetPlayerCoords(player, property.entranceLocation)

    MySQL.insert.await(
        "INSERT INTO property_player (property_id, player) VALUES (?, ?)",
        { property.id, Bridge.GetPlayerIdentifier(player) }
    )
end

Bridge.onReady(LoadProperties)
Bridge.onPlayerLoad(onPlayerLoad)
Bridge.onPlayerUnload(onPlayerUnload)

exports("GetPropertyById", GetPropertyById)
exports("GetPropertyPlayerIsIn", GetPropertyPlayerIsIn)
