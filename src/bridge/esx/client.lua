local ESX = exports['es_extended']:getSharedObject()
local onReadyCallback

function Bridge.onReady(cb)
    onReadyCallback = cb
    RegisterNetEvent("esx:playerLoaded", function()
        CreateThread(cb)
    end)
end

function Bridge.HelpNotification(message, time)
    ESX.ShowHelpNotification(message, true, true, (time or 5) * 1000)
end

CreateThread(function()
    Wait(100)

    if ESX.IsPlayerLoaded() and onReadyCallback then
        Debug.Log("Loading properties")
        onReadyCallback()
    end
end)
