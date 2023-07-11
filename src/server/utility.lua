---Check if the player has a permission for a property.
---@type function[]
CheckPermission = {
    ---@param source number
    ---@param propertyId number
    ---@return boolean
    [PERMISSION.MEMBER] = function(source, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return false end

        ---@type Key
        local key = property:getPlayerKey(source)
        return
            key.permission == PERMISSION.MEMBER or
            key.permission == PERMISSION.RENTER or
            key.permission == PERMISSION.OWNER
    end,
    ---@param source number
    ---@param propertyId number
    ---@return boolean
    [PERMISSION.RENTER] = function(source, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return false end

        ---@type Key
        local key = property:getPlayerKey(source)
        return
            key.permission == PERMISSION.RENTER or
            key.permission == PERMISSION.OWNER
    end,
    ---@param source number
    ---@param propertyId number
    ---@return boolean
    [PERMISSION.OWNER] = function(source, propertyId)
        local property = GetPropertyById(propertyId)
        if not property then return false end

        ---@type Key
        local key = property:getPlayerKey(source)
        return key.permission == PERMISSION.OWNER
    end,
}
