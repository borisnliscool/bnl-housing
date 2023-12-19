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
local handler = function(options)
    if ServerSpecialProps[options.model] then
        lib.print.warn(("Special prop handler %s already exists, overwriting."):format(options.model))
    end

    ServerSpecialProps[options.model] = options
    lib.print.info(("Registered special prop handler for %s"):format(options.model))
end

exports("registerSpecialProp", handler)

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
