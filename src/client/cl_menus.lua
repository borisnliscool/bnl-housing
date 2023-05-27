Menus = {}

Menus.entrance = function(point)
    local data = lib.callback.await(cache.resource .. ":server:getPropertyPermission", false, point.property_id)
    local options = {}

    if data and data.permission then
        local permissionOptions = {
            owner = {
                {
                    label = "Owner",
                }
            },
            member = {
                {
                    label = "Member",
                }
            },
            renter = {
                {
                    label = "Renter",
                }
            }
        }

        options = table.merge({
                {
                    label = "Enter"
                }
            },
            permissionOptions[data.permission],
            true
        )
    else
        options = {
            {
                label = "Knock",
            }
        }
    end

    return {
        id = cache.resource .. "_entrance",
        title = locale("menu.entrance.title"),
        position = 'top-left',
        options = options
    }
end
