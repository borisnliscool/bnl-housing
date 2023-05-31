Config = {}

-- Framework you're using
-- options: "esx"
Config.framework = "esx"

Config.inviteRange = 10.0
-- the way for the menu to show up,
-- options: "walk", "keypress"
Config.interactMode = "keypress"
-- the way players get listed in menus
-- options: "name", "id", "both"
Config.playerTag = "both"

Config.points = {}
Config.points.entrance = {
    viewDistance = 10.0,
    -- this is only used if Config.interactMode is set to "keypress"
    interact = {
        -- https://docs.fivem.net/docs/game-references/controls/
        padIndex = 0,
        control = 38,
        name = "INPUT_PICKUP"
    },
    marker = {
        type = 1,
        size = vec3(.8, .8, 1.0),
        offset = vec3(0, 0, -1),
        rotation = vec3(0, 0, 0),
        color = {
            r = 0,
            g = 192,
            b = 255,
            a = 100
        },
        bob = false,
        faceCamera = false
    }
}
-- the in-property point is set as the same
-- as the entrance point, if you'd like to
-- customize this you can do that
Config.points.property = Config.points.entrance

Config.blips = {
    house = {
        owner = {
            sprite = 40,
            color = 2,
        },
        member = {
            sprite = 40,
            color = 3,
            short = true
        },
        renter = {
            sprite = 40,
            color = 5,
        },
    },
    warehouse = {
        owner = {
            sprite = 473,
            color = 2,
        },
        member = {
            sprite = 473,
            color = 3,
            short = true
        },
        renter = {
            sprite = 473,
            color = 5,
        },
    },
    office = {
        owner = {
            sprite = 475,
            color = 2,
        },
        member = {
            sprite = 475,
            color = 3,
            short = true
        },
        renter = {
            sprite = 475,
            color = 5,
        },
    }
}
