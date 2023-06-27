--! WARNING !--
-- The qb-core bridge for bnl-housing is currenlty untested!
-- It might just straight up not work.
-- I made this based upon other scripts using qb-core.
-- If you are experienced with qb-core, and can test it, please contact me via discord.
--! WARNING !--

local QBCore = exports['qb-core']:GetCoreObject()
local onReadyCallback

---Register the ready callback.
---@param cb function
function Bridge.onReady(cb)
    onReadyCallback = cb
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent("bnl-housing:bridge:server:playerLoad")
        CreateThread(onReadyCallback)
    end)

    AddEventHandler("QBCore:Client:OnPlayerUnload", function()
        TriggerServerEvent("bnl-housing:bridge:server:playerUnload")
    end)
end

---Show a regular notification to the player
---@param message string
---@param type "info" | "success" | "error"
---@param time number | nil
function Bridge.Notification(message, type, time)
    local convertedTypes = {
        primary = "info",
        success = "success",
        error = "error",
    }
    QBCore.Functions.Notify(message, convertedTypes[type], (time or 5) * 1000)
end
