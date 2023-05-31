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
    local key = lib.callback.await("bnl-housing:server:getPropertyKey", false, property.id)

    local main = {
        id = "bnl-housing_entrance",
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
                lib.callback.await("bnl-housing:server:entrance:enter", false, property.id)
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
        id = "bnl-housing_property",
        title = locale("menu.property.title"),
        position = 'top-left',
        options = {
            {
                label = locale("menu.property.exit"),
                onSelect = function(_, _, _)
                    lib.callback.await("bnl-housing:server:property:exit", false, property.id)
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
                lib.callback.await("bnl-housing:server:property:exit", false, property.id)
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
            onSelect = function()
                Menus.manage_keys(property)
            end
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
        id = "bnl-housing_invite",
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
            return {
                label = FormatPlayerTag(player.name, player.id),
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

Menus.manage_keys = function(property)
    local main = {
        id = "bnl-housing_manage_keys",
        title = locale("menu.property.manage_keys"),
        position = 'top-left',
    }

    main.options = {
        {
            label = locale("menu.manage_keys.give"),
            onSelect = function()
                Menus.keys_give(property)
            end
        },
        {
            label = locale("menu.manage_keys.take"),
            onSelect = function()
                Menus.keys_take(property)
            end
        }
    }

    ShowMenu(main)
end

Menus.keys_give = function(property)
    local main = {
        id = "bnl-housing_manage_keys_give",
        title = locale("menu.property.manage_keys"),
        position = 'top-left',
    }

    local keys = property:getKeys()

    main.options = table.map(
        lib.getNearbyPlayers(GetEntityCoords(cache.ped), Config.inviteRange, true),
        function(data)
            local serverId = GetPlayerServerId(data.id)
            local playerName = lib.callback.await("bnl-housing:server:getPlayerName", false, serverId)

            if table.findOne(keys, function(key) return key.serverId == serverId end) then
                return
            end

            return {
                label = FormatPlayerTag(playerName, serverId),
                onSelect = function()
                    -- todo
                    -- give the selected player a member key
                end
            }
        end,
        true
    )

    if #main.options == 0 then
        table.insert(main.options, {
            label = locale("menu.manage_keys.no_players")
        })
    end

    ShowMenu(main)
end

Menus.keys_take = function(property)
    local keys = property:getKeys()

    local main = {
        id = "bnl-housing_manage_keys_take",
        title = locale("menu.property.manage_keys"),
        position = 'top-left',
    }

    main.options = table.map(keys, function(key)
        if key.permission ~= "member" then
            return
        end
        return {
            label = ("%s - %s"):format(key.player, locale(("permission.%s"):format(key.permission))),
            onSelect = function()
                Debug.Log(key)
            end
        }
    end, true)

    if #main.options == 0 then
        table.insert(main.options, {
            label = locale("menu.manage_keys.no_keys")
        })
    end

    ShowMenu(main)
end
