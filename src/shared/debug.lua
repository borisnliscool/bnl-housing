Debug = {}

function string:Format(...)
    local args = { ... }
    for key, value in pairs(args) do
        args[key] = "^3" .. tostring(value) .. "^0"
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    return string.format(self, table.unpack(args))
end

local function formatString(...)
    local args = { ... }
    local str = ""

    for _, value in pairs(args) do
        if type(value) == "table" then
            str = str .. " " .. json.encode(value, { indent = true })
        else
            str = str .. " " .. value
        end
    end

    return str
end

Debug.Log = function(...)
    if GetConvar("bnl:debug", 'false') == 'true' then
        return print("[^4DEBUG^0]" .. formatString(...))
    end
end

Debug.Error = function(...)
    if GetConvar("bnl:debug", 'false') == 'true' then
        return print("[^1ERROR^0]" .. formatString(...))
    end
end
