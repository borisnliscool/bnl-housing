Menus = {}

local function ShowMenu(menu)
    lib.registerMenu(menu, function(selected, scrollIndex, args)
        if menu.options[selected].onSelect then
            menu.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)
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
        ShowMenu(main)
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

    ShowMenu(main)
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
        ShowMenu(main)
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
            onSelect = function()
                Menus.invite(property)
            end
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

    ShowMenu(main)
end

Menus.invite = function(property)
    local main = {
        id = cache.resource .. "_property",
        title = locale("menu.property.invite"),
        position = 'top-left',
    }

    local function InvitePlayer(serverId)
        -- todo
        -- add logic for inviting players inside this
        -- should give the outside player a prompt
        -- to press a key to accept the invite
        Debug.Log(("Inviting player #%s inside."):Format(serverId))
    end

    main.options = table.map(
        property:getOutsidePlayers(),
        function(player)
            -- todo
            -- add an option to the config to only show
            -- the player id, player name, or both
            return {
                label = ("[#%s] %s"):format(player.id, player.name),
                onSelect = function()
                    InvitePlayer(player.id)
                end
            }
        end,
        true
    )

    if #main.options == 0 then
        table.insert(main.options, {
            label = locale("menu.invite.no_players")
        })
    end

    ShowMenu(main)
end
