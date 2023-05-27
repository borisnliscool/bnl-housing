ClientFunctions = {}

function RegisterClientFunction(name, func)
    local eventName = ("%s:%s"):format(cache.resource, name)

    if IsDuplicityVersion() then
        -- server
        ClientFunctions[name] = function(source, ...)
            TriggerClientEvent(eventName, source, table.unpack({ ... }))
        end
    else
        -- client
        RegisterNetEvent(eventName, function(...)
            func(table.unpack({...}))
        end)
        ClientFunctions = nil
    end
end

RegisterClientFunction("FadeIn", DoScreenFadeIn)
RegisterClientFunction("FadeOut", DoScreenFadeOut)