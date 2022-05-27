return {
    ["prop_ld_int_safe_01"] = {
        closeText = "Press [E] to open the safe",
        marker = {
            sprite = 2,
            offset = vector3(0.0, 0.0, 1.25),
            scale = vector3(0.25, 0.25, 0.25),
            rotation = vector3(180.0, 0.0, 0.0),
            color = {
                255,
                255,
                255,
                255
            },
            bob = false,
            faceCamera = true
        },
        outline = {
            color = {
                255,
                255,
                255,
                255
            },
            shader = 1
        },
        range = 1.5,
        func = function(prop)
            if (prop.data.code) then
                local input = lib.inputDialog("Safe is Locked", {"Enter Code"})
                if (input) then
                    local code = tonumber(input[1])
                    local data = lib.callback.await("bnl-housing:server:openSafe", false, {
                        prop_id = prop.id,
                        code = code
                    })
                    if (data.ret) then
                        exports.ox_inventory:openInventory('stash', data.safe_id)
                    else
                        lib.defaultNotify(data.notification)
                    end
                end
            end
        end,
    },
}