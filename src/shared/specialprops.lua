---@param str string
---@return { type: "event", event: string } | { type: "export", resource: string, export: string }
local parseHandlerString = function(str)
    local prefix, suffix = str:match("^(.-)%.(.*)")

    if not prefix or not suffix then
        error("Invalid handler string: " .. str)
    end

    if prefix == "event" then
        return { type = "event", event = suffix }
    end

    if prefix == "export" then
        local resource, export = suffix:match("([^:]+):([^:]+)")

        if not resource or not export then
            error("Invalid handler string: " .. str)
        end

        return { type = "export", resource = resource, export = export }
    end

    error("Invalid handler prefix: " .. prefix)
end


---@param handler { type: "event", event: string } | { type: "export", resource: string, export: string }
---@param ... any
local callHandler = function(handler, ...)
    local args = ...

    if handler.type == "event" then
        return TriggerEvent(handler.event, args)
    end

    if handler.type == "export" then
        local success, result = pcall(function()
            -- I hate exports, like, why is this like this??
            local export = exports[handler.resource][handler.export]
            export(export, args)
        end)
        if not success then
            error(("Failed to execute special prop export: %s.%s"):format(handler.resource, handler.export))
        end
        return result
    end
end

---@param handlers SpecialPropEventHandler?
---@param ... any
CallSpecialPropHandlers = function(handlers, ...)
    if not handlers then return end
    local args = ...

    CreateThread(function()
        if type(handlers) == "string" then
            return callHandler(
                parseHandlerString(handlers),
                args
            )
        end

        if type(handlers) == "table" then
            for _, handler in pairs(handlers) do
                CreateThread(function()
                    CallSpecialPropHandlers(handler, args)
                end)
            end
        end
    end)
end
