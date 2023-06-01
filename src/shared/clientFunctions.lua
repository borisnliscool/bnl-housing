ClientFunctions = {}

---@param func function
function RegisterClientFunction(func)
    local eventName = ("bnl-housing:%s"):format(table.count(ClientFunctions))

    if IsDuplicityVersion() then
        return function(source, ...)
            return lib.callback.await(eventName, source, ...)
        end
    else
        lib.callback.register(eventName, function(...)
            return func(...)
        end)
        return eventName
    end
end

CreateThread(function()
    ClientFunctions.FadeIn = RegisterClientFunction(DoScreenFadeIn)
    ClientFunctions.FadeOut = RegisterClientFunction(DoScreenFadeOut)
    ClientFunctions.SetupInPropertyPoints = RegisterClientFunction(SetupInPropertyPoints)
    ClientFunctions.RemoveInPropertyPoints = RegisterClientFunction(RemoveInPropertyPoints)
    ClientFunctions.SetClipboard = RegisterClientFunction(lib.setClipboard)
end)
