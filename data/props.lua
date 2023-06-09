---@param name string
local function loadProps(name)
    local file = ('data/props/%s.lua'):format(name)
    local datafile = LoadResourceFile("bnl-housing", file)
    local func, err = load(datafile, ('@%s/%s'):format("bnl-housing", file))

    if not func or err then
        return error(err)
    end

    return func()
end

Data = {}
Data.Props = {
    bar = loadProps("bar"),
    bathroom = loadProps("bathroom"),
    bins = loadProps("bins"),
    construction = loadProps("construction"),
    electrical = loadProps("electrical"),
    equipment = loadProps("equipment"),
    garage = loadProps("garage"),
    industrial = loadProps("industrial"),
    interior = loadProps("interior"),
    kitchen = loadProps("kitchen"),
    minigame = loadProps("minigame"),
    office = loadProps("office"),
    outdoor = loadProps("outdoor"),
    potted = loadProps("potted"),
    recreational = loadProps("recreational"),
    rubbish = loadProps("rubbish"),
    seating = loadProps("seating"),
    storage = loadProps("storage"),
    utility = loadProps("utility"),
    wallsAndFences = loadProps("wallsAndFences"),
}

return Data.Props
