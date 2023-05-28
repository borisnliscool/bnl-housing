Menus = {}

local function ShowMenu(menu, cb)
    lib.registerMenu(menu, cb)
    lib.showMenu(menu.id)
end

Menus.entrance = function(property)
    local key = lib.callback.await(cache.resource .. ":server:getPropertyKey", false, property.id)

    local main = {
        id = cache.resource .. "_entrance",
        title = locale("menu.entrance.title"),
        position = 'top-left',
    }

    if not key or not key.permission then
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
                    lib.callback.await(cache.resource .. ":server:entrance:enter", false, property.id)
                end
            }
        },
        permissionOptions[key.permission],
        true
    )

    ShowMenu(main, function(selected, scrollIndex, args)
        if main.options[selected].onSelect then
            main.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)
end

Menus.property = function(property)
    local main = {
        id = cache.resource .. "_property",
        title = locale("menu.property.title"),
        position = 'top-left',
    }

    main.options = {
        {
            label = "Exit",
            onSelect = function(selected, scrollIndex, args)
                lib.callback.await(cache.resource .. ":server:property:exit", false, property.id)
            end
        }
    }

    ShowMenu(main, function(selected, scrollIndex, args)
        if main.options[selected].onSelect then
            main.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)

    -- if not property.key or not property.key.permission then
    --     return
    -- end
end
