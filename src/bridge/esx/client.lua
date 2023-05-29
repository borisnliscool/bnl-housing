local ESX = exports['es_extended']:getSharedObject()

function Bridge.onReady(cb)
    RegisterNetEvent("esx:playerLoaded", function()
        CreateThread(cb)
    end)
end

function Bridge.Notify(message, time)
    ESX.ShowHelpNotification(message, true, true, (time or 5) * 1000)
end

CreateThread(function()
    Wait(100)

    if ESX.IsPlayerLoaded() then
        Debug.Log("Loading properties")
        SetupProperties()
    end
end)
