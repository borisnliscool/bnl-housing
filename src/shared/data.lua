---Load data from file
---@param name string
---@return table?
function LoadData(name)
    local file = ('data/%s.lua'):format(name)
    local datafile = LoadResourceFile("bnl-housing", file)
    local func, err = load(datafile, ('@%s/%s'):format("bnl-housing", file))

    if not func or err then
        return lib.print.error("Failed to load data", err)
    end

    return func()
end

Data = {
    Shells = LoadData("shells"),
    Props = LoadData("props"),
}
