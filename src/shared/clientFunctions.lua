ClientFunctions = {}

---Register a client function
---@param func function
---@return string|function
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
    ClientFunctions.StartBusySpinner = RegisterClientFunction(StartBusySpinner)
    ClientFunctions.BusyspinnerOff = RegisterClientFunction(BusyspinnerOff)
    ClientFunctions.HelpNotification = RegisterClientFunction(Bridge.HelpNotification)
    ClientFunctions.StartMinimapOverlay = RegisterClientFunction(StartMinimapOverlay)
    ClientFunctions.StopMinimapOverlay = RegisterClientFunction(StopMinimapOverlay)
end)
