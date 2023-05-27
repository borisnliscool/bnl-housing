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
