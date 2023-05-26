function table.map(table, func)
    local ret = {}
    for key, value in pairs(table) do
        local data = func(value, key)
        if data then
            ret[key] = data
        end
    end
    return ret
end