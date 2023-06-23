AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end

    local destroyedProperties = {}

    for _, property in pairs(Properties) do
        for _, player in pairs(property.players) do
            player:warpOutOfProperty()
        end

        table.insert(destroyedProperties, property.id)
        property:destroy()
    end

    Debug.Log(Format("Destoyed properties: %s", table.concat(destroyedProperties, ", ")))
end)
