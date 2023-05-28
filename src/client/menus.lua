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
        options = {
            {
                label = locale("menu.entrance.knock"),
            }
        },
    }

    if not key or not key.permission then
        ShowMenu(main, function(selected, scrollIndex, args)
            if main.options[selected].onSelect then
                main.options[selected].onSelect(selected, scrollIndex, args)
            end
        end)
        return
    end

    main.options = table.map({
        {
            label = locale("menu.entrance.enter"),
            onSelect = function()
                lib.callback.await(cache.resource .. ":server:entrance:enter", false, property.id)
            end
        }
    }, function(option)
        return (not option.permission or lib.table.contains(option.permission, property.key.permission)) and option
    end)

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
        options = {
            {
                label = locale("menu.property.exit"),
                onSelect = function(_, _, _)
                    lib.callback.await(cache.resource .. ":server:property:exit", false, property.id)
                end
            }
        }
    }

    if not property.key or not property.key.permission then
        ShowMenu(main, function(selected, scrollIndex, args)
            if main.options[selected].onSelect then
                main.options[selected].onSelect(selected, scrollIndex, args)
            end
        end)
        return
    end

    main.options = table.map({
        {
            label = locale("menu.property.exit"),
            onSelect = function(_, _, _)
                lib.callback.await(cache.resource .. ":server:property:exit", false, property.id)
            end
        },
        {
            label = "test",
            onSelect = function(_, _, _)
                print("test")
            end,
            permissions = { "owner" }
        }
    }, function(option)
        return (not option.permissions or lib.table.contains(option.permissions, property.key.permission)) and option
    end)

    ShowMenu(main, function(selected, scrollIndex, args)
        if main.options[selected].onSelect then
            main.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)
end
