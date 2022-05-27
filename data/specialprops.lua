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
        func = function(data)
            Logger.Success("Executed function for prop_ld_int_safe_01")
        end,
    }
}