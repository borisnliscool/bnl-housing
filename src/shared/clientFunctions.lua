-- todo
-- could make this work like: ClientFunctions.<name> = RegisterClientFunction
-- wouldn't have the logical event names anymore though
-- we would need to keep a count or something

ClientFunctions = {}

function RegisterClientFunction(name, func)
    local eventName = ("%s:%s"):format(cache.resource, name)

    if IsDuplicityVersion() then
        -- server
        ClientFunctions[name] = function(source, ...)
            TriggerClientEvent(eventName, source, ...)
        end
    else
        -- client
        RegisterNetEvent(eventName, function(...)
            func(...)
        end)
        ClientFunctions = nil
    end
end

CreateThread(function()
    RegisterClientFunction("FadeIn", DoScreenFadeIn)
    RegisterClientFunction("FadeOut", DoScreenFadeOut)
    RegisterClientFunction("SetupInPropertyPoints", SetupInPropertyPoints)
    RegisterClientFunction("RemoveInPropertyPoints", RemoveInPropertyPoints)
end)
