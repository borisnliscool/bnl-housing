--! WARNING !--
-- The ox_core bridge for bnl-housing is currenlty untested!
-- It might just straight up not work. 
-- I made this based upon other scripts using ox_core.
-- If you are experienced with ox_core, and can test it, please contact me via discord.
--! WARNING !--

local onReadyCallback

---Register the ready callback.
---@param cb function
function Bridge.onReady(cb)
    onReadyCallback = cb
    AddEventHandler('ox:playerLoaded', function()
        CreateThread(onReadyCallback)
    end)
end

---Show a regular notification to the player
---@param message string
---@param type "info" | "success" | "error"
---@param time number?
function Bridge.Notification(message, type, time)
    lib.notify({
        description = message,
        type = type,
        duration = (time or 5) * 1000
    })
end
