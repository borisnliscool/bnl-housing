AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end

    for _, property in pairs(Properties) do
        for _, player in pairs(property.players) do
            player:warpOutOfProperty()
        end
        property:destroy()
    end
end)
