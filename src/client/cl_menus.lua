Menus = {}

local function ShowMenu(menu, cb)
    lib.registerMenu(menu, cb)
    lib.showMenu(menu.id)
end

Menus.entrance = function(point)
    local data = lib.callback.await(cache.resource .. ":server:getPropertyKey", false, point.property_id)

    local main = {
        id = cache.resource .. "_entrance",
        title = locale("menu.entrance.title"),
        position = 'top-left',
    }

    if not data or not data.permission then
        main.options = {
            {
                label = "Knock",
            }
        }

        ShowMenu(main, function(selected, scrollIndex, args)
            if main.options[selected].onSelect then
                main.options[selected].onSelect(selected, scrollIndex, args)
            end
        end)
        return
    end

    local permissionOptions = {
        owner = {
            {
                label = "Owner",
                onSelect = function(selected, scrollIndex, args)
                    print(selected, scrollIndex, args)
                end
            }
        },
        member = {
            {
                label = "Member",
                onSelect = function(selected, scrollIndex, args)
                    print(selected, scrollIndex, args)
                end
            }
        },
        renter = {
            {
                label = "Renter",
                onSelect = function(selected, scrollIndex, args)
                    print(selected, scrollIndex, args)
                end
            }
        }
    }

    main.options = table.merge({
            {
                label = "Enter",
                onSelect = function()
                    lib.callback.await(cache.resource .. ":server:entrance:enter", false, point.property_id)
                end
            }
        },
        permissionOptions[data.permission],
        true
    )

    ShowMenu(main, function(selected, scrollIndex, args)
        if main.options[selected].onSelect then
            main.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)
end
