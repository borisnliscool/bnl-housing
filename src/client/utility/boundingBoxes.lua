---@param entity Entity
---@return table
local function GetEntityBoundingBox(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local pad = 0.001

    local retval = {
        -- Bottom
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, min.z - pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, min.z - pad),

        -- Top
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, max.z + pad),
        GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, max.z + pad)
    }

    return retval
end

---@param point1 vector3
---@param point2 vector3
local function Line(point1, point2)
    local color = { r = 255, g = 255, b = 255, a = 255 }
    DrawLine(point1.x, point1.y, point1.z, point2.x, point2.y, point2.z, color.r, color.g, color.b, color.a)
end

---@param box table
local function DrawEdges(box)
    -- Bottom
    Line(box[1], box[2])
    Line(box[2], box[3])
    Line(box[3], box[4])
    Line(box[4], box[1])

    -- Top
    Line(box[5], box[6])
    Line(box[6], box[7])
    Line(box[7], box[8])
    Line(box[8], box[5])

    -- Connectors
    Line(box[1], box[5])
    Line(box[2], box[6])
    Line(box[3], box[7])
    Line(box[4], box[8])
end

---@param point1 vector3
---@param point2 vector3
---@param point3 vector3
local function Face(point1, point2, point3)
    local color = { r = 0, g = 0, b = 200, a = 50 }
    DrawPoly(point1.x, point1.y, point1.z, point2.x, point2.y, point2.z, point3.x, point3.y, point3.z, color.r, color.g,
        color.b, color.a)
end

---@param box table
local function DrawFaces(box)
    -- Front
    Face(box[1], box[2], box[5])
    Face(box[5], box[2], box[6])

    -- Right
    Face(box[2], box[3], box[6])
    Face(box[6], box[3], box[7])

    -- Back
    Face(box[3], box[4], box[7])
    Face(box[7], box[4], box[8])

    -- Left
    Face(box[4], box[1], box[8])
    Face(box[8], box[1], box[5])

    -- Bottom
    Face(box[2], box[1], box[3])
    Face(box[1], box[4], box[3])

    -- Top
    Face(box[5], box[6], box[7])
    Face(box[7], box[8], box[5])
end

---@param entity Entity
function DrawEntityBoundingBox(entity)
    local box = GetEntityBoundingBox(entity)
    DrawEdges(box)
    DrawFaces(box)
end
