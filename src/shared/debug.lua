Debug = {}

---Format a string with the default format function, appart from adding fivem color codes to inserted values
---@param str string
---@param ... unknown
---@return string
function Format(str, ...)
    local args = { ... }
    for key, value in pairs(args) do
        args[key] = "^3" .. tostring(value) .. "^0"
    end

    return string.format(str, table.unpack(args))
end

---Regular string formatting, but fixed for prints
---@param ... unknown
---@return string
local function formatString(...)
    local args = { ... }
    local str = ""

    for _, value in pairs(args) do
        if type(value) == "table" then
            str = str .. " " .. json.encode(value, { indent = true })
        elseif type(value) == "boolean" then
            str = str .. " " .. (value and "true" or "false")
        else
            str = str .. " " .. value
        end
    end

    return str
end

---Basic log statement, only works if the bnl:debug convar is set.
---@param ... unknown
---@return nil
function Debug.Log(...)
    if GetConvar("bnl:debug", 'false') == 'true' then
        return print("[^4DEBUG^0]" .. formatString(...))
    end
end

---Basic error statement, only works if the bnl:debug convar is set.
---@param ... unknown
---@return nil
function Debug.Error(...)
    return error("[^1ERROR^0]" .. formatString(...))
end
