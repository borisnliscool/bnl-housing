function table.map(list, func, noIndex)
    local ret = {}

    for key, value in pairs(list) do
        local data = func(value, key)
        if data ~= nil then
            if noIndex then
                table.insert(ret, data)
            else
                ret[key] = data
            end
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

function table.merge(t1, t2, ignoreKeys)
    local ret = t1
    if ignoreKeys then
        for key, value in pairs(t2) do
            table.insert(ret, value)
        end
    else
        for key, value in pairs(t2) do
            ret[key] = value
        end
    end
    return ret
end

function table.tovector(list)
    return vec3(list.x, list.y, list.z)
end

function table.count(list)
    local count = 0
    for _, _ in pairs(list) do
        count = count + 1
    end
    return count
end