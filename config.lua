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
