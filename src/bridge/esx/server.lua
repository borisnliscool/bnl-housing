local ESX = exports['es_extended']:getSharedObject()
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
    RegisterNetEvent("esx:playerLoaded", function(source)
        onPlayerLoadCallback(source)
    end)
end

---Register the player unload callback.
---@param cb function
function Bridge.onPlayerUnload(cb)
    onPlayerUnloadCallback = cb
    RegisterNetEvent("esx:playerDropped", function(source)
        onPlayerUnloadCallback(source)
    end)
end

---Get a player's identifier
---@param source number
---@return string
function Bridge.GetPlayerIdentifier(source)
    return ESX.GetPlayerFromId(source).getIdentifier()
end

---Get a player's name
---@param source number
---@return string
function Bridge.GetPlayerName(source)
    return ESX.GetPlayerFromId(source).getName()
end

---This function has to get the name from the database, because it can also be called for identifiers that are online in the server.
---@param identifier string
---@return string
function Bridge.GetPlayerNameFromIdentifier(identifier)
    local data = MySQL.single.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { identifier })
    return ("%s %s"):format(data.firstname, data.lastname)
end

--- Get a player's server id (source) from their identifier
---@param identifier string
---@return number?
function Bridge.GetServerIdFromIdentifier(identifier)
    local player = ESX.GetPlayerFromIdentifier(identifier)
    return player and player.source or nil
end

---Get all player server ids (sources).
---@return table
function Bridge.GetAllPlayers()
    return table.map(ESX.GetPlayers(), function(p) return p.source end)
end

---Get a player's money
---@param source number
---@return number
function Bridge.GetMoney(source)
    return ESX.GetPlayerFromId(source).getAccount("bank").money
end

---Remove money from a player
---@param source any
function Bridge.RemoveMoney(source, amount)
    return ESX.GetPlayerFromId(source).removeAccountMoney("bank", amount)
end
