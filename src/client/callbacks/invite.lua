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
            Config.Keybinds.invite.name),
        Config.inviteExpire
    )

    while time < Config.inviteExpire do
        Wait(0)
        if IsControlJustReleased(Config.Keybinds.invite.padIndex, Config.Keybinds.invite.control) then
            Bridge.HelpNotification(" ", 0.001)
            return true
        end
    end

    return false
end)
