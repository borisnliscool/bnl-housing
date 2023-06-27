local ESX = exports['es_extended']:getSharedObject()
local onReadyCallback

---Register the ready callback.
---@param cb function
function Bridge.onReady(cb)
    onReadyCallback = cb
    RegisterNetEvent("esx:playerLoaded", function()
        CreateThread(onReadyCallback)
    end)
end

---Show a regular notification to the player
---@param message string
---@param type "info" | "success" | "error"
---@param time number?
function Bridge.Notification(message, type, time)
    ESX.ShowNotification(message, type, (time or 5) * 1000)
end

-- This code is only really used for development.
-- It makes sure the script gets loaded correctly
-- on restart, as the playerLoaded event doesn't
-- get triggered on restart
CreateThread(function()
    Wait(100)

    if ESX.IsPlayerLoaded() and onReadyCallback then
        Debug.Log("Loading properties")
        onReadyCallback()
    end
end)
