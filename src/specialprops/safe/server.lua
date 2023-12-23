local allowedOpens = {}

exports.ox_inventory:registerHook('openInventory', function(payload)
    local data = allowedOpens[tostring(payload.source)]
    local offset = GetGameTimer() - data.time

    if offset > 1000 then
        return false -- Took too long for the client to try and open the safe
    end

    if payload.inventoryId ~= data.stashId then
        return false -- Didn't open the correct stash
    end

    allowedOpens[tostring(payload.source)] = nil

    return true
end, {
    print = true,
    inventoryFilter = {
        '^property.safe.[%w]+',
    }
})

RegisterNetEvent("bnl-housing:specialprops:safe:open", function(enteredCode, propertyId, propId)
    local prop = exports["bnl-housing"]:getPropertyProp(propertyId, propId)
    if not prop then return end

    local currentCode = prop.metadata.getPrivate("code")

    if not currentCode then
        prop.metadata.setPrivate("code", enteredCode:sub(1, 4))
        currentCode = enteredCode
    end

    if currentCode ~= enteredCode then
        ClientFunctions.Notification(source, locale("specialprops.safe.invalid_code"), "error")
        return
    end

    local stashId = "property.safe." .. propId

    allowedOpens[tostring(source)] = {
        time = GetGameTimer(),
        stashId = stashId
    }

    exports.ox_inventory:RegisterStash(stashId, locale("specialprops.safe"), 25, 1000 * 1000)
    exports.ox_inventory:forceOpenInventory(source, 'stash', stashId)
end)

RegisterNetEvent("bnl-housing:specialprops:safe:changeCode", function(oldCode, _newCode, propertyId, propId)
    local prop = exports["bnl-housing"]:getPropertyProp(propertyId, propId)
    if not prop then return end

    local newCode = _newCode:sub(1, 4)
    local currentCode = prop.metadata.getPrivate("code")

    if not currentCode then
        prop.metadata.setPrivate("code", newCode)
        ClientFunctions.Notification(source, locale("specialprops.safe.updated_code", newCode), "success")
        return
    end

    if currentCode ~= oldCode then
        ClientFunctions.Notification(source, locale("specialprops.safe.invalid_code"), "error")
        return
    end

    ClientFunctions.Notification(source, locale("specialprops.safe.updated_code", newCode), "success")
    prop.metadata.setPrivate("code", newCode)
end)
