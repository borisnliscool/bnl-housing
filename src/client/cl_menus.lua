Menus = {}

Menus.entrance = function(point)
    local data = lib.callback.await(cache.resource .. ":server:getPropertyKey", false, point.property_id)

    local main = {
        id = cache.resource .. "_entrance",
        title = locale("menu.entrance.title"),
        position = 'top-left',
    }

    if data and data.permission then
        local permissionOptions = {
            owner = {
                {
                    label = "Owner",
                    onSelect = function(secondary, args)
                        print(secondary, args)
                    end
                }
            },
            member = {
                {
                    label = "Member",
                    onSelect = function(secondary, args)
                        print(secondary, args)
                    end
                }
            },
            renter = {
                {
                    label = "Renter",
                    onSelect = function(secondary, args)
                        print(secondary, args)
                    end
                }
            }
        }

        main.options = table.merge({
                {
                    label = "Enter"
                }
            },
            permissionOptions[data.permission],
            true
        )

        main.onSelected = function(selected, secondary, args)
            if main.options[selected].onSelect then
                main.options[selected].onSelect(secondary, args)
            end
        end

        return main
    end

    main.options = {
        {
            label = "Knock",
        }
    }
    return main
end
