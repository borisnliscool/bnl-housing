---Round a number to the given amount of decimals
---@param num number
---@param decimals number | nil
---@return number
function math.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end
