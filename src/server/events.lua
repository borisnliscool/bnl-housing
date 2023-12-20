AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end

    local destroyedProperties = table.map(Properties, function(property)
        property:destroy()
        return property.id
    end)

    lib.print.verbose(("Destoyed properties: %s"):format(
        table.concat(destroyedProperties, ", "))
    )
end)
