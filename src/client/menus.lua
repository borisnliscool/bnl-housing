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
        if not option.permissions or lib.table.contains(option.permissions, property.key.permission) then
            return option
        end
    end, true)

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

    local function notImplemented()
        Debug.Log("This feature is ^1not yet implemented^0!")
        lib.notify({
            type = "error",
            description = "This feature is not yet implemented!"
        })
    end

    main.options = table.map({
        {
            label = locale("menu.property.exit"),
            onSelect = function(_, _, _)
                lib.callback.await(cache.resource .. ":server:property:exit", false, property.id)
            end
        },
        {
            label = locale("menu.property.invite"),
            permissions = { "member", "renter", "owner" },
            onSelect = notImplemented
        },
        {
            label = locale("menu.property.decorate"),
            permissions = { "member", "renter", "owner" },
            onSelect = notImplemented
        },
        {
            label = locale("menu.property.manage_keys"),
            permissions = { "owner" },
            onSelect = notImplemented
        },
        {
            label = locale("menu.property.sell"),
            permissions = { "owner" },
            onSelect = notImplemented
        },
        {
            label = locale("menu.property.rent_out"),
            permissions = { "owner" },
            onSelect = notImplemented
        },
    }, function(option)
        if not option.permissions or lib.table.contains(option.permissions, property.key.permission) then
            return option
        end
    end, true)

    ShowMenu(main, function(selected, scrollIndex, args)
        if main.options[selected].onSelect then
            main.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)
end
