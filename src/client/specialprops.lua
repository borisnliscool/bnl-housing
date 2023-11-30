---@class Interact
---@field interactMode "walk" | "keypress" | "target"
---@field keybind Keybind?
---@field target OxTargetOption?
---@field range number
---@field marker Marker?
---@field outline Outline?
---@field helpText string?

---@class ClientHandlers
---@field interact SpecialPropEventHandler?
---@field spawn SpecialPropEventHandler?
---@field destroy SpecialPropEventHandler?

---@class SpecialPropClientHandlerOptions
---@field model string
---@field interact Interact?
---@field handlers { client: ClientHandlers }?

---@type table<string, SpecialPropClientHandlerOptions>
ClientSpecialProps = {}

---@param options SpecialPropClientHandlerOptions
local handler = function(options)
    if ClientSpecialProps[options.model] then
        Debug.Log(Format("Special prop handler %s already exists, overwriting.", options.model))
    end

    ClientSpecialProps[options.model] = options
    Debug.Log(Format("Registered special prop handler for %s", options.model))
end

exports("registerSpecialProp", handler)

---

RegisterNetEvent("bnl-housing:on:enterProperty", function(propertyId)
    local property = Properties[propertyId]
    if not property then return end

    for _, prop in ipairs(property.props) do
        if not ClientSpecialProps[prop.model] then
            goto continue
        end

        CallSpecialPropHandlers(
            ClientSpecialProps[prop.model].handlers?.client?.spawn,
            prop
        )

        ::continue::
    end
end)

RegisterNetEvent("bnl-housing:on:leaveProperty", function(propertyId)
    local property = Properties[propertyId]
    if not property then return end

    for _, prop in ipairs(property.props) do
        if not ClientSpecialProps[prop.model] then
            goto continue
        end

        CallSpecialPropHandlers(
            ClientSpecialProps[prop.model].handlers?.client?.destroy,
            prop
        )

        ::continue::
    end
end)
