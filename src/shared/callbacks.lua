---Register a callback with middleware functions
---@param name string
---@param ... unknown
function RegisterMiddlewareCallback(name, ...)
    local functions = { ... }

    lib.callback.register(name, function(...)
        local lastResult = nil
        for _, func in pairs(functions) do
            local result = func(...)
            lastResult = result

            if not result then
                return result
            end
        end
        return lastResult
    end)
end
