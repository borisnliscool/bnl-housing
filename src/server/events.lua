AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end

    local destroyedProperties = {}

    for _, property in pairs(Properties) do
        for _, player in pairs(property.players) do
            -- todo this doesnt work I think
            player:warpOutOfProperty()
        end

        table.insert(destroyedProperties, property.id)
        property:destroy()
    end

    lib.print.verbose(("Destoyed properties: %s"):format(table.concat(destroyedProperties, ", ")))
end)
