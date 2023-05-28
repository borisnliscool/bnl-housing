local function loadData(name)
    local file = ('data/%s.lua'):format(name)
    local datafile = LoadResourceFile(cache.resource, file)
    local func, err = load(datafile, ('@%s/%s'):format(cache.resource, file))

    if not func or err then
        return error(err)
    end

    return func()
end

Data = {
    Shells = loadData("shells"),
    Props = loadData("props"),
}
