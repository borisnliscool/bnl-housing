local function loadData(name)
    local file = ('data/%s.lua'):format(name)
    local datafile = LoadResourceFile("bnl-housing", file)
    local func, err = load(datafile, ('@%s/%s'):format("bnl-housing", file))

    if not func or err then
        return error(err)
    end

    return func()
end

Data = {
    Shells = loadData("shells"),
    Props = loadData("props"),
}
