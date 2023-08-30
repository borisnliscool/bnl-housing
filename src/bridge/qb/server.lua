--! WARNING !--
-- The qb-core bridge for bnl-housing is currenlty untested!
-- It might just straight up not work.
-- I made this based upon other scripts using qb-core.
-- If you are experienced with qb-core, and can test it, please contact me via discord.
--! WARNING !--

local QBCore = exports['qb-core']:GetCoreObject()
local onReadyCallback, onPlayerLoadCallback, onPlayerUnloadCallback

---Register the ready callback.
---@param cb function
function Bridge.onReady(cb)
    onReadyCallback = cb
    CreateThread(function()
        Wait(10)
        onReadyCallback()
    end)
end

---Register the player load callback.
---@param cb function
function Bridge.onPlayerLoad(cb)
    onPlayerLoadCallback = cb
    RegisterNetEvent("bnl-housing:bridge:server:playerLoad", function(player)
        onPlayerLoadCallback(player)
    end)
end

---Register the player unload callback.
---@param cb function
function Bridge.onPlayerUnload(cb)
    onPlayerUnloadCallback = cb
    RegisterNetEvent("bnl-housing:bridge:server:playerUnload", function(player)
        onPlayerUnloadCallback(player)
    end)
end

---Get a player's identifier
---@param source number
---@return string
function Bridge.GetPlayerIdentifier(source)
    return QBCore.Functions.GetPlayer(source).PlayerData.citizenid
end

---Get a player's name
---@param source number
---@return string
function Bridge.GetPlayerName(source)
    local player = QBCore.Player.GetPlayer(source)
    return ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
end

---This function has to get the name from the database, because it can also be called for identifiers that are online in the server.
---@param identifier string
---@return string
function Bridge.GetPlayerNameFromIdentifier(identifier)
    local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
    if not player then
        player = QBCore.Player.GetOfflinePlayer(identifier)
    end
    return ("%s %s"):format(player.firstname, player.lastname)
end

--- Get a player's server id (source) from their identifier
---@param identifier string
---@return number?
function Bridge.GetServerIdFromIdentifier(identifier)
    local player = table.findOne(QBCore.Functions.GetPlayers(), function(p)
        return p.PlayerData.citizenid == identifier
    end)
    return player and player.PlayerData.source or nil
end

---Get all player server ids (sources).
---@return table
function Bridge.GetAllPlayers()
    return table.map(QBCore.Functions.GetPlayers(), function(p) return p.PlayerData.source end)
end

---Get a player's money
---@param source number
---@return number
function Bridge.GetMoney(source)
    -- todo: implement
end

---Remove money from a player
---@param player number | string
---@param amount number
function Bridge.RemoveMoney(player, amount)
    -- todo: implement
end

---Add money to a player
---@param player number | string
---@param amount number
function Bridge.AddMoney(player, amount)
    -- todo: implement
end
