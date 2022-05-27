lib.locale()
resource = GetCurrentResourceName()

lowerBy = vector3(0.0, 0.0, 25.0)

function math.round(number, decimals)
    decimals = decimals or 1
    local multiplier = 10 ^ decimals
    return math.floor(number * multiplier + 0.5) / multiplier
end

function math.trim(value)
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

function GetShellById(shell_id)
    for _,shell in pairs(shells) do
        if shell.id == shell_id then
            return shell
        end
    end
    return nil
end

Logger = {}
Logger.Enabled = true

Logger.Log = function(...)
    if not Logger.Enabled then return end
    local args = {...}
    print(string.format("^7[^4INFO^7] %s^7", FormatLoggingString(args)))
end

Logger.Info = Logger.Log

Logger.Warn = function(...)
    if not Logger.Enabled then return end
    local args = {...}
    print(string.format("^7[^3WARN^7] %s^7", FormatLoggingString(args)))
end

Logger.Error = function(...)
    if not Logger.Enabled then return end
    local args = {...}
    print(string.format("^7[^1ERROR^7] %s^7", FormatLoggingString(args)))
end

Logger.Success = function(...)
    if not Logger.Enabled then return end
    local args = {...}
    print(string.format("^7[^2SUCCESS^7] %s^7", FormatLoggingString(args)))
end

function FormatLoggingString(...)
    local args = {...}
    local msg = ""
    for _,arg in pairs(args) do
        if (type(arg) == 'table') then
            msg = msg .. json.encode(arg, {indent = true})
        else
            msg = msg .. tostring(arg)
        end
    end
    return msg
end

function V4ToV3(vector4)
    return vector3(vector4.x, vector4.y, vector4.z)
end

function JsonCoordToVector3(coord)
    local coord = json.decode(coord)
    return vector3(coord.x, coord.y, coord.z)
end

function IsPedVehicleDriver(ped, vehicle)
    return ped == GetPedInVehicleSeat(vehicle, -1)
end

function IsVehicleEmpty(vehicle)
    if (not vehicle) then return false end
    if (not DoesEntityExist(vehicle)) then return true end

    for i=-1,16 do
        if GetPedInVehicleSeat(vehicle, i) ~= 0 then
            return false
        end
    end
    return true
end

function GetPlayersInVehicle(vehicle)
    if (not vehicle) then return false end
    if (not DoesEntityExist(vehicle)) then return true end

    local players = {}
    for i=-1,16 do
        if GetPedInVehicleSeat(vehicle, i) ~= 0 then
            local ped = GetPedInVehicleSeat(vehicle, i)
            local serverId = GetPlayerServerId(ped)
            if (serverId ~= 0) then
                table.insert(players, serverId)
            end
        end
    end
    return players
end

function GetPropertyPropById(property, prop_id)
    if (property.decoration == nil) then
        return nil
    end

    if (type(property.decoration) == 'string') then
        property.decoration = json.decode(property.decoration)
    end

    for _,prop in pairs(property.decoration) do
        if (prop.id == prop_id) then
            return prop
        end
    end

    return nil
end

-- Taken from ox_inventory by @Overextended All credit goes to them!
-- I take no credit for this code. (Changed little a bit)
-- https://github.com/overextended/ox_inventory
function data(name)
	local file = ('data/%s.lua'):format(name)
	local datafile = LoadResourceFile(resource, file)
	local func, err = load(datafile, ('@%s/%s'):format(resource, file))

	if err then
		Logger.Error(err)
	end

	return func()
end