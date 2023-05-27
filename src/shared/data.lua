Data = {}

local function loadData(name)
    local file = ('src/data/%s.lua'):format(name)
    local datafile = LoadResourceFile(cache.resource, file)
    local func, err = load(datafile, ('@%s/%s'):format(cache.resource, file))

    if not func or err then
        return error(err)
    end

    return func()
end

CreateThread(function()
    Data.Shells = loadData("shells")
    Data.Props = loadData("props")
end)