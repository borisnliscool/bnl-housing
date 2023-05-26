Bridge = {}

local version = IsDuplicityVersion() and "server" or "client"
local script = ("src/bridge/%s/%s.lua"):format(Config.framework, version)
local file = LoadResourceFile(cache.resource, script)

if not file then
    return error(("Can't find bridge for framework '%s'"):format(Config.framework))
end

local func, err = load(file)

if not func or err then
    return error(err)
end

func()