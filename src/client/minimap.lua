local overlay = nil

---@param interior string
---@param location vector3
---@param zoom number
function StartMinimapOverlay(interior, location, zoom)
    overlay = true

    CreateThread(function()
        while overlay do
            Wait(0)
    
            local coords = cache.coords
            SetRadarAsInteriorThisFrame(interior, 0, 0, cache.heading, zoom)
        end
    end)
end

function StopMinimapOverlay()
    overlay = false
end