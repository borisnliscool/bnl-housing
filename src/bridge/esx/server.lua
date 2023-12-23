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
---@return string | nil
function Bridge.GetPlayerNameFromIdentifier(identifier)
    local data = MySQL.single.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { identifier })
    if not data then return nil end
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
    return table.map(ESX.GetExtendedPlayers(), function(p) return p.source end)
end

---Get a player's money
---@param player number | string
---@return number | nil
function Bridge.GetMoney(player)
    if type(player) == "number" then
        return ESX.GetPlayerFromId(player)?.getAccount("bank").money
    end

    if type(player) == "string" then
        local queryResult = MySQL.single.await("SELECT accounts FROM users WHERE identifier = ?", {
            player
        })
        if not queryResult then return end

        local accounts = json.decode(queryResult.accounts)
        return accounts.bank
    end
end

---Remove money from a player
---@param player number | string
---@param amount number
function Bridge.RemoveMoney(player, amount)
    if type(player) == "number" then
        return ESX.GetPlayerFromId(player).removeAccountMoney("bank", amount)
    end

    if type(player) == "string" then
        local query = [[
            UPDATE users
            SET accounts = JSON_SET(accounts, '$.bank', JSON_UNQUOTE(JSON_EXTRACT(accounts, '$.bank')) - ?)
            WHERE identifier = ?;
        ]]
        MySQL.query.await(query, { amount, player })
    end
end

---Add money to a player
---@param player number | string
---@param amount number
function Bridge.AddMoney(player, amount)
    if type(player) == "number" then
        return ESX.GetPlayerFromId(player).addAccountMoney("bank", amount)
    end

    if type(player) == "string" then
        local query = [[
            UPDATE users
            SET accounts = JSON_SET(accounts, '$.bank', JSON_UNQUOTE(JSON_EXTRACT(accounts, '$.bank')) + ?)
            WHERE identifier = ?;
        ]]
        MySQL.query.await(query, { amount, player })
    end
end
