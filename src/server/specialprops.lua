---@class ServerHandlers
---@field interact SpecialPropEventHandler?
---@field spawn SpecialPropEventHandler?
---@field destroy SpecialPropEventHandler?

---@class SpecialPropServerHandlerOptions
---@field model string
---@field handlers { server: ServerHandlers }?

---@type table<string, SpecialPropServerHandlerOptions>
ServerSpecialProps = {}

---@param options SpecialPropServerHandlerOptions
RegisterSpecialProp = function(options)
    if ServerSpecialProps[options.model] then
        Debug.Log(Format("Special prop handler %s already exists, overwriting.", options.model))
    end

    ServerSpecialProps[options.model] = options
    Debug.Log(Format("Registered special prop handler for %s", options.model))
end

---

RegisterNetEvent("bnl-housing:server:specialprops:interact", function(propertyId, propId)
    local property = GetPropertyPlayerIsIn(source)
    if not property or property.id ~= propertyId then
        return
    end

    local prop = table.findOne(property.props, function(prop)
        return prop.id == propId
    end)

    if not prop then
        return
    end

    CallSpecialPropHandlers(
        ServerSpecialProps[prop.model].handlers?.server?.interact,
        prop:getData()
    )
end)
