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
        Debug.Log(Format("Special prop handler %s already exists, overwriting.", options.model))
    end

    ServerSpecialProps[options.model] = options
    Debug.Log(Format("Registered special prop handler for %s", options.model))
end

exports("registerSpecialProp", handler)
