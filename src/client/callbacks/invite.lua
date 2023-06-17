lib.callback.register("bnl-housing:client:handleInvite", function(address)
    local time = 0

    CreateThread(function()
        while time < Config.inviteExpire do
            Wait(1000)
            time = time + 1
        end
    end)

    Bridge.HelpNotification(
        locale("notification.invite", address.streetName .. " " .. address.buildingNumber,
            Config.inviteKeybind.name),
        Config.inviteExpire
    )

    while time < Config.inviteExpire do
        Wait(0)
        if IsControlJustReleased(Config.inviteKeybind.padIndex, Config.inviteKeybind.control) then
            Bridge.HelpNotification(" ", 0.001)
            return true
        end
    end

    return false
end)
