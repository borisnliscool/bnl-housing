Debug = {}

function Format(str, ...)
    local args = { ... }
    for key, value in pairs(args) do
        args[key] = "^3" .. tostring(value) .. "^0"
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    return string.format(str, table.unpack(args))
end

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

function Debug.Log(...)
    if GetConvar("bnl:debug", 'false') == 'true' then
        return print("[^4DEBUG^0]" .. formatString(...))
    end
end

function Debug.Error(...)
    if GetConvar("bnl:debug", 'false') == 'true' then
        return print("[^1ERROR^0]" .. formatString(...))
    end
end
