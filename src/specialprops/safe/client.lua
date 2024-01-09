local register = function()
    -- Because there's no server handlers, we can register the whole prop clientsided.
    -- It's not recommended to do it this way, but in this case it results in less files.
    exports["bnl-housing"]:registerSpecialProp({
        model = "p_v_43_safe_s",

        interact = {
            range = 2.0,
            helpText = locale("specialprops.safe.open_help", "INPUT_PICKUP"),

            keybind = {
                padIndex = 0,
                control = 38,
                name = "INPUT_PICKUP"
            },

            marker = {
                type = 2,
                offset = vector3(0.0, 0.0, 1.75),
                size = vector3(0.25, 0.25, 0.25),
                rotation = vector3(180.0, 0.0, 0.0),
                color = {
                    r = 255,
                    g = 255,
                    b = 255,
                    a = 200
                },
                faceCamera = true
            },
        },

        handlers = {
            client = {
                interact = "event.bnl-housing:specialprops:safe:interact"
            },
        }
    })
end

CreateThread(register)

local interact = function(prop)
    local openSafe = function()
        local input = lib.inputDialog(locale("specialprops.safe.enter_code"), {
            {
                type = 'number',
                label = locale("specialprops.safe.four_digit"),
                placeholder = "6969",
                icon = "lock",
                required = true,
                min = 1000,
                max = 9999
            },
        })

        if not input then return end

        local code = input[1]
        if not code then return end

        TriggerServerEvent("bnl-housing:specialprops:safe:open", tostring(code), prop.propertyId, prop.id)
    end

    local changeCode = function()
        local input = lib.inputDialog(locale("specialprops.safe.change_code"), {
            {
                type = 'number',
                label = locale("specialprops.safe.old_code"),
                placeholder = "6969",
                icon = "lock",
                required = true,
                min = 1000,
                max = 9999
            },
            {
                type = 'number',
                label = locale("specialprops.safe.new_code"),
                placeholder = "6969",
                icon = "lock",
                required = true,
                min = 1000,
                max = 9999
            },
        })

        if not input then return end

        local oldCode, newCode = input[1], input[2]
        if not oldCode or not newCode then return end

        TriggerServerEvent("bnl-housing:specialprops:safe:changeCode", tostring(oldCode), tostring(newCode),
            prop.propertyId, prop.id)
    end

    lib.registerMenu({
        id = "bnl-housing:specialprops:safe",
        title = locale("specialprops.safe"),
        options = {
            {
                label = locale("specialprops.safe.open"),
                icon = "unlock"
            },
            {
                label = locale("specialprops.safe.change_code"),
                icon = "pen"
            }
        },
    }, function(selected)
        local options = {
            openSafe,
            changeCode,
        }
        options[selected]()
        lib.hideMenu()
    end)

    lib.showMenu("bnl-housing:specialprops:safe")
end

AddEventHandler("bnl-housing:specialprops:safe:interact", interact)
