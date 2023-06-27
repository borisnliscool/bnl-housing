Config = {}

---@enum Framework
FRAMEWORKS = {
    auto = "auto",
    esx = "esx",
}
---Framework you're using (automatic should be fine)
---@type Framework
Config.framework = FRAMEWORKS.auto

---The way for the menu to show up,
---@type "walk" | "keypress"
Config.interactMode = "keypress"
---The way players get listed in menus
---@type "name" | "id" | "both"
Config.playerTag = "both"
---Time in seconds for invites to expire
---@type number
Config.inviteExpire = 15
---Range for being able to invite players
---@type number
Config.inviteRange = 10.0

---@class Keybind
---@field padIndex number
---@field control number
---@field name string

---@type table
Config.Keybinds = {}
---@type Keybind
Config.Keybinds.invite = {
    padIndex = 0,
    control = 58,
    name = "INPUT_THROW_GRENADE"
}
---@type Keybind
Config.Keybinds.exitGarage = {
    padIndex = 0,
    control = 87,
    name = "INPUT_VEH_FLY_THROTTLE_UP"
}
---@type Keybind
Config.Keybinds.interact = {
    padIndex = 0,
    control = 38,
    name = "INPUT_PICKUP"
}

---@type table
Config.VehicleBlacklist = {
    classes = {
        10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21
    },
    models = {
        -- Put any vehicle hash in here, make sure it is a string, and an output
        -- of GetEntityModel (https://docs.fivem.net/natives/?_0x9F47B058362C84B5)

        -- For example:
        2069146067, -- Oppressor MK2
        -845961253, -- Liberator
    }
}

---@type number
Config.entranceTransition = 500

---@class Point
---@field viewDistance number
---@field interact Keybind
---@field marker Marker

---@class Marker
---@field type number
---@field size vector3
---@field vehicleSize number
---@field offset vector3
---@field rotation vector3
---@field color table
---@field bob boolean
---@field faceCamera boolean

---@type table
Config.points = {}

---@type Point
Config.points.entrance = {
    viewDistance = 10.0,
    -- this is only used if Config.interactMode is set to "keypress"
    interact = Config.Keybinds.interact,
    marker = {
        type = 1,
        size = vec3(.8, .8, 1.0),
        vehicleSize = 3,
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
---@type Point
Config.points.property = Config.points.entrance

---@class Blip
---@field sprite number
---@field color number
---@field short boolean | nil
---@field display number | nil
---@field scale number | nil

---@class PropertyBlips
---@field owner Blip
---@field member Blip
---@field renter Blip

---@type table
Config.blips = {
    ---@type PropertyBlips
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
    ---@type PropertyBlips
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
    ---@type PropertyBlips
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
    },
    ---@type PropertyBlips
    garage = {
        owner = {
            sprite = 357,
            color = 2,
        },
        member = {
            sprite = 357,
            color = 3,
            short = true
        },
        renter = {
            sprite = 357,
            color = 5,
        },
    },
}
