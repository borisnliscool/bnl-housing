--! WARNING !--
-- The ox_core bridge for bnl-housing is currenlty untested!
-- It might just straight up not work.
-- I made this based upon other scripts using ox_core.
-- If you are experienced with ox_core, and can test it, please contact me via discord.
--! WARNING !--

local file = ('imports/%s.lua'):format(IsDuplicityVersion() and 'server' or 'client')
local import = LoadResourceFile('ox_core', file)
local chunk = assert(load(import, ('@@ox_core/%s'):format(file)))
chunk()

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
    RegisterNetEvent("ox:playerLoaded", function(player)
        onPlayerLoadCallback(player)
    end)
end

---Register the player unload callback.
---@param cb function
function Bridge.onPlayerUnload(cb)
    onPlayerUnloadCallback = cb
    RegisterNetEvent("ox:playerLogout", function(player)
        onPlayerUnloadCallback(player)
    end)
end

---Get a player's identifier
---@param source number
---@return string
function Bridge.GetPlayerIdentifier(source)
    ---@diagnostic disable-next-line: undefined-global
    return Ox.GetPlayer(source).charid
end

---Get a player's name
---@param source number
---@return string
function Bridge.GetPlayerName(source)
    ---@diagnostic disable-next-line: undefined-global
    return Ox.GetPlayer(source).name
end

---This function has to get the name from the database, because it can also be called for identifiers that are online in the server.
---@param identifier string
---@return string
function Bridge.GetPlayerNameFromIdentifier(identifier)
    local data = MySQL.single.await("SELECT firstname, lastname FROM characters WHERE identifier = ?",
        { tonumber(identifier) })
    return ("%s %s"):format(data.firstname, data.lastname)
end

--- Get a player's server id (source) from their identifier
---@param identifier string
---@return number?
function Bridge.GetServerIdFromIdentifier(identifier)
    ---@diagnostic disable-next-line: undefined-global
    local player = table.findOne(Ox.GetPlayers(), function(p)
        return p.charid == identifier
    end)
    return player and player.source or nil
end

---Get all player server ids (sources).
---@return table
function Bridge.GetAllPlayers()
    ---@diagnostic disable-next-line: undefined-global
    return table.map(Ox.GetPlayers(), function(p) return p.source end)
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
