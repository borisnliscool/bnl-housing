function RegisterHousingCommands()
    lib.addCommand('housing', {
        help = locale("commands.housing.help"),
        restricted = 'group.admin'
    }, function(source)
        ClientFunctions.ShowUI(source, "adminMenu")
    end)
end
