Data = {}

---@type { [string]: { [string]: PropData[] } }
Data.Props = {
    bar = LoadData("props/bar") --[[@as PropData[] ]],
    bathroom = LoadData("props/bathroom") --[[@as PropData[] ]],
    bins = LoadData("props/bins") --[[@as PropData[] ]],
    construction = LoadData("props/construction") --[[@as PropData[] ]],
    electrical = LoadData("props/electrical") --[[@as PropData[] ]],
    equipment = LoadData("props/equipment") --[[@as PropData[] ]],
    garage = LoadData("props/garage") --[[@as PropData[] ]],
    industrial = LoadData("props/industrial") --[[@as PropData[] ]],
    interior = LoadData("props/interior") --[[@as PropData[] ]],
    kitchen = LoadData("props/kitchen") --[[@as PropData[] ]],
    minigame = LoadData("props/minigame") --[[@as PropData[] ]],
    office = LoadData("props/office") --[[@as PropData[] ]],
    outdoor = LoadData("props/outdoor") --[[@as PropData[] ]],
    potted = LoadData("props/potted") --[[@as PropData[] ]],
    recreational = LoadData("props/recreational") --[[@as PropData[] ]],
    rubbish = LoadData("props/rubbish") --[[@as PropData[] ]],
    seating = LoadData("props/seating") --[[@as PropData[] ]],
    storage = LoadData("props/storage") --[[@as PropData[] ]],
    utility = LoadData("props/utility") --[[@as PropData[] ]],
    walls = LoadData("props/walls") --[[@as PropData[] ]],
}

CreateThread(function()
    if not Config.paidDecoration then
        for _, category in pairs(Data.Props) do
            for _, prop in pairs(category) do
                (prop --[[@as PropData]]).price = 0
            end
        end
    end
end)

return Data.Props
