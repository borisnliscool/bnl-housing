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

function table.find(list, func, keepIndex)
    keepIndex = keepIndex == true and true or false
    local ret = {}
    for key, value in pairs(list) do
        if func(value, key) then
            if keepIndex then
                ret[key] = value
            else
                table.insert(ret, value)
            end
        end
    end
    return ret
end

function table.findOne(list, func)
    for key, value in pairs(list) do
        if func(value, key) then
            return value, key
        end
    end
end
