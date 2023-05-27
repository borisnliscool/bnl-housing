Debug = {}

Debug.Log = function(...)
    local args = { ... }
    local str = ""

    for key, value in pairs(args) do
        if type(value) == "table" then
            str = str .. "'" .. json.encode(value, { indent = true }) .. "'"
        else
            str = str .. " " .. value
        end
    end

    print("[^4DEBUG^0]" .. str)
end
