local ESX = exports['es_extended']:getSharedObject()

function Bridge.onReady(cb)
    CreateThread(function()
        Wait(10)
        cb()
    end)
end

function Bridge.GetPlayerIdentifier(source)
    return ESX.GetPlayerFromId(source).getIdentifier()
end

function Bridge.GetPlayerName(source)
    return ESX.GetPlayerFromId(source).getName()
end

-- This function has to get the name from the database,
-- because it can also be called for identifiers that
-- are online in the server.
function Bridge.GetPlayerNameFromIdentifier(identifier)
    local data = MySQL.single.await("SELECT firstname, lastname FROM users WHERE identifier = ?", { identifier })
    return ("%s %s"):format(data.firstname, data.lastname)
end