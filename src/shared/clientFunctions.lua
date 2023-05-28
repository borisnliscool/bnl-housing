ClientFunctions = {}
local functionCount = 0

function RegisterClientFunction(func)
    functionCount = functionCount + 1
    local eventName = ("%s:%s"):format(cache.resource, functionCount)

    if IsDuplicityVersion() then
        return function(source, ...)
            TriggerClientEvent(eventName, source, ...)
        end
    else
        RegisterNetEvent(eventName, function(...)
            func(...)
        end)
    end
end

CreateThread(function()
    ClientFunctions.FadeIn = RegisterClientFunction(DoScreenFadeIn)
    ClientFunctions.FadeOut = RegisterClientFunction(DoScreenFadeOut)
    ClientFunctions.SetupInPropertyPoints = RegisterClientFunction(SetupInPropertyPoints)
    ClientFunctions.RemoveInPropertyPoints = RegisterClientFunction(RemoveInPropertyPoints)
end)
