local ESX = exports['es_extended']:getSharedObject()

function Bridge.Notify(message, time)
    ESX.ShowHelpNotification(message, true, true, (time or 5) * 1000)
end
