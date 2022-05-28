-- This is a copy of bnl-blipmanager (https://github.com/borisnliscool/bnl-blipmanager)
-- It's better practice to use the bnl-blipmanager resource instead of this to keep up to date.

local blips = {}
local blipcount = 0

local AddBlipToList = function(blip, category)
    blipcount = blipcount + 1

    if blips[category] == nil then
        blips[category] = {}
    end

    blip.id = blipcount

    table.insert(blips[category], blip)

    return blip
end

local ChangeBlipCategory = function(blip, category)
    local old_category = blip.category
    local old_index = blip.id

    table.remove(blips[old_category], old_index)

    blip.category = category
    
    if blips[category] == nil then
        blips[category] = {}
    end

    table.insert(blips[category], blip)

    return blip
end

local UpdateBlip = function(blip)
    local id = blip.id

    if blips[blip.category][id] ~= blip then
        blips[blip.category][id] = blip
    end

    return blip
end

local ToggleCategory = function(category, state)
    if category == nil then category = 'unknown' end
    if blips[category] ~= nil then
        for _, blip in pairs(blips[category]) do
            if state == nil then 
                if blip:isVisible() then blip:hide() else blip:show() end 
            else
                if state == true then blip:show() else blip:hide() end 
            end
        end
    end
end

local GetCategory = function(category)
    if category == nil then category = 'unknown' end
    return blips[category]
end

local RemoveCategory = function(category)
    if category == nil then category = 'unknown' end
    if blips[category] ~= nil then
        for _, blip in pairs(blips[category]) do
            blip:destroy()
        end
        blips[category] = nil
    end
end

local GetAllCategories = function()
    return blips
end

local CreateBlip = function(coord, sprite, color, name, scale, category, display, short)
    local self = {}

    if coord == nil then return nil end

    self.sprite = sprite or 1
    self.color = color or 1
    self.name = name or 'Unnamed Blip'
    self.scale = scale or 1.0
    self.display = display or 2
    self.category = category or 'unknown'
    self.resource = nil
    if short == nil then self.short = true else self.short = short end

    local blp = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite(blp, self.sprite)
    SetBlipColour(blp, self.color)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.name)
    EndTextCommandSetBlipName(blp)

    SetBlipDisplay(blp, self.display)
    SetBlipScale(blp, self.scale)
    SetBlipAsShortRange(blp, self.short)

    self.blip = blp

    self.setCoord = function(coord)
        if self == nil then return false end
        SetBlipCoords(self.blip, coord.x, coord.y, coord.z)
    end

    self.setSprite = function(sprite)
        if self == nil then return false end
        SetBlipSprite(self.blip, sprite)
    end

    self.setColor = function(color)
        if self == nil then return false end
        SetBlipColour(self.blip, color)
    end

    self.setName = function(name)
        if self == nil then return false end
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(self.blip)
    end

    self.setScale = function(scale)
        if self == nil then return false end
        SetBlipScale(self.blip, scale)
    end

    self.setDisplay = function(display)
        if self == nil then return false end
        SetBlipDisplay(self.blip, display)
    end

    self.setRoute = function(route, color)
        if self == nil then return false end
        SetBlipRoute(self.blip, route)
        if color ~= nil then SetBlipRouteColour(self.blip, color) end
    end

    self.setAsShortRange = function(state)
        if state == nil then state = true end
        SetBlipAsShortRange(self.blip, state)
    end

    self.setRotation = function(rotation)
        if self == nil then return false end
        SetBlipRotation(self.blip, math.ceil( rotation or 0 ))
    end

    self.destroy = function()
        if self ~= nil and self.blip ~= nil then
            RemoveBlip(self.blip)
        end
        self = nil
        return nil
    end

    self.isVisible = function()
        if self == nil then return false end
        return GetBlipInfoIdDisplay(self.blip) ~= 0
    end

    self.hide = function()
        if self == nil then return false end
        SetBlipDisplay(self.blip, 0)
    end

    self.show = function()
        if self == nil then return false end
        SetBlipDisplay(self.blip, self.display)
    end

    self.setCategory = function(category)
        if self == nil then return false end
        ChangeBlipCategory(self, category)
    end

    self.setResource = function(resource)
        if self == nil then return false end
        self.resource = resource
        UpdateBlip(self)
    end

    AddBlipToList(self, self.category)
    return self
end

RegisterNetEvent("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then
        for _, category in pairs(blips) do
            for _, blip in pairs(category) do
                if blip.resource == resource then
                    blip:destroy()
                end
            end
        end
    end
end)

BlipManager = {
    CreateBlip = CreateBlip,
    GetCategory = GetCategory,
    RemoveCategory = RemoveCategory,
    ToggleCategory = ToggleCategory,
    GetAllCategories = GetAllCategories
}