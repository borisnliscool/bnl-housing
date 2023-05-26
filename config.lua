Config = {}

-- Framework you're using, supported: 'esx'
Config.framework = "esx"

Config.entrance = {
    viewDistance = 10.0,
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

Config.blips = {
    house = {
        owner = {
            sprite = 40,
            color = 2,
        },
        member = {
            sprite = 40,
            color = 3,
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
        },
        renter = {
            sprite = 475,
            color = 5,
        },
    }
}
