Menus = {}

---@param menu table
local function ShowMenu(menu)
    lib.registerMenu(menu, function(selected, scrollIndex, args)
        if menu.options[selected].onSelect then
            menu.options[selected].onSelect(selected, scrollIndex, args)
        end
    end)
    lib.showMenu(menu.id)
end

function Menus.entrance(property)
    ---@type Key
    local key = lib.callback.await("bnl-housing:server:getPropertyKey", false, property.id)

    local main = {
        id = "bnl-housing_entrance",
        title = locale("menu.entrance.title", property.address.streetName, property.address.buildingNumber),
        position = 'top-left',
        options = {},
    }

    if property.isForSale then
        table.insert(main.options, {
            label = locale("menu.entrance.buy", property.saleData.price),
            onSelect = function()
                -- todo
                --  add some sort of confirmation
                lib.callback.await("bnl-housing:server:property:buyProperty", false, property.id)
            end
        })
    end

    if property.isForRent then
        table.insert(main.options, {
            label = locale("menu.entrance.rent", property.rentData.price),
            onSelect = function()
                -- todo
                --  add some sort of confirmation
                lib.callback.await("bnl-housing:server:property:rentProperty", false, property.id)
            end
        })
    end

    if not key or not key.permission or key.permission == PERMISSION.VISITOR then
        table.insert(main.options, {
            label = locale("menu.entrance.knock"),
            onSelect = function()
                lib.callback.await("bnl-housing:server:entrance:knock", false, property.id)
            end
        })
        ShowMenu(main)
        return
    end

    table.insert(main.options, {
        label = locale("menu.entrance.enter"),
        onSelect = function()
            if cache.vehicle and IsVehicleBlacklisted(cache.vehicle) then
                Bridge.Notification(locale("notification.property.blacklistedVehicle"), "error")
                return
            end
            lib.callback.await("bnl-housing:server:entrance:enter", false, property.id)
        end
    })

    main.options = table.map(main.options, function(option)
        if not option.permissions or lib.table.contains(option.permissions, property.key.permission) then
            return option
        end
    end, true)

    ShowMenu(main)
end

function Menus.property(property)
    local function notImplemented()
        Debug.Log("This feature is ^1not yet implemented^0!")
        lib.notify({
            type = "error",
            description = "This feature is not yet implemented!"
        })
    end

    local main = {
        id = "bnl-housing_property",
        title = locale("menu.property.title", property.address.streetName, property.address.buildingNumber),
        position = 'top-left',
        options = {}
    }

    local options = {
        {
            label = locale("menu.property.exit"),
            onSelect = function()
                lib.callback.await("bnl-housing:server:property:exit", false, property.id)
            end
        },
        {
            label = locale("menu.property.links"),
            onSelect = function()
                Menus.links(property)
            end,
            active = function()
                return #property.links > 0
            end
        },
        {
            label = locale("menu.property.invite"),
            permissions = { PERMISSION.MEMBER, PERMISSION.RENTER, PERMISSION.OWNER },
            onSelect = function()
                Menus.invite(property)
            end
        },
        {
            label = locale("menu.property.decorate"),
            permissions = { PERMISSION.MEMBER, PERMISSION.RENTER, PERMISSION.OWNER },
            onSelect = function()
                ShowUI("propPicker")
            end
        },
        {
            label = locale("menu.property.manage_keys"),
            permissions = { PERMISSION.RENTER, PERMISSION.OWNER },
            onSelect = function()
                Menus.manage_keys(property)
            end
        },
        {
            label = locale("menu.property.sell"),
            permissions = { PERMISSION.OWNER },
            onSelect = notImplemented
        },
        {
            label = locale("menu.property.rent_out"),
            permissions = { PERMISSION.OWNER },
            onSelect = notImplemented
        },
    }

    main.options = table.map(options, function(option)
        if option.active and not option.active() then return end
        if option.permissions and (not property.key or not lib.table.contains(option.permissions, property.key.permission)) then
            return
        end
        return option
    end, true)

    ShowMenu(main)
end

function Menus.invite(property)
    local main = {
        id = "bnl-housing_invite",
        title = locale("menu.property.invite"),
        position = 'top-left',
    }

    local function InvitePlayer(serverId)
        lib.callback("bnl-housing:server:property:invite", false, property.id, serverId)
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

function Menus.manage_keys(property)
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

function Menus.keys_give(property)
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
                    lib.callback.await("bnl-housing:server:property:giveKey", false, property.id, serverId)
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

function Menus.keys_take(property)
    local keys = property:getKeys()

    local main = {
        id = "bnl-housing_manage_keys_take",
        title = locale("menu.property.manage_keys"),
        position = 'top-left',
    }

    main.options = table.map(keys, function(key)
        if key.permission ~= PERMISSION.MEMBER then
            return
        end
        return {
            label = ("%s - %s"):format(key.player, locale(("permission.%s"):format(key.permission))),
            onSelect = function()
                lib.callback.await("bnl-housing:server:property:removeKey", false, property.id, key.id)
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

function Menus.links(property)
    local main = {
        id = "bnl-housing_links",
        title = locale("menu.property.links"),
        position = 'top-left',
    }

    main.options = table.map(property.links, function(id)
        local linkedProperty = Properties[id]

        return {
            label = linkedProperty.address.streetName .. " " .. linkedProperty.address.buildingNumber,
            onSelect = function()
                lib.callback.await("bnl-housing:server:entrance:enter", false, linkedProperty.id)
            end
        }
    end)

    ShowMenu(main)
end
