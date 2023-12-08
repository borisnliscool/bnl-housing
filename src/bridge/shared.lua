Bridge = {}

---@return table
local function GetAllResources()
    local resources = {}

    for i = 0, GetNumResources(), 1 do
        local resourceName = GetResourceByFindIndex(i)
        if resourceName and GetResourceState(resourceName) == "started" then
            table.insert(resources, resourceName)
        end
    end

    return resources
end

---@return Framework?
local function DetectFramework()
    local resources = GetAllResources()

    if lib.table.contains(resources, "es_extended") then
        return FRAMEWORKS.esx
    elseif lib.table.contains(resources, "ox_core") then
        return FRAMEWORKS.ox
    elseif lib.table.contains(resources, "qb-core") then
        return FRAMEWORKS.qb
    end

    lib.print.error("Unable to auto detect framework.")
end

---@type Framework?
local framework = Config.framework ~= FRAMEWORKS.auto and Config.framework or DetectFramework()

local version = IsDuplicityVersion() and "server" or "client"
local script = ("src/bridge/%s/%s.lua"):format(framework, version)
local file = LoadResourceFile("bnl-housing", script)

if not file then
    return error(("Can't find bridge for framework '%s'"):format(framework))
end

local func, err = load(file)

if not func or err then
    return error(err)
end

func()
