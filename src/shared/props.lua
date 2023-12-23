---@param model string
---@return table?
function GetPropFromModel(model)
    for _, category in pairs(Data.Props) do
        local d = category[model]
        if d then
            return d
        end
    end
end

---@param props table
---@return table
function FormatPlacedProps(props)
    return table.map(props, function(prop)
        local data = GetPropFromModel(prop.model)
        return {
            id = prop.id,
            model = prop.model,
            name = data and data.name or prop.model,
            location = json.encode(prop.location),
            rotation = json.encode(prop.rotation),
            metadata = json.encode(prop.metadata),
        }
    end)
end
