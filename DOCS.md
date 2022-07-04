<div id="top"></div>

<br />
<div align="center">
    <h1>Documentation</h1>
</div>

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Commands

Note you need the permission `bnl-housing:admin` to use any of these commands.

```md
 - /housing help | Shows a help message in the F8 menu

 - /housing current | Shows info about the property you are in

 - /housing property <id> | Shows info about a property with given id

 - /housing permission | Shows your permission level in the current property

 - /housing coord | Shows the internally used coord system & copies to your clipboard

 - /housing enter <id> | Enter the property with given id
```

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Exports

These exports are all server side, I might add more in the future. The usage can also be found in the code. If I haven't added a description down here, it's probably because the method names should explain it enough.

```lua
exports['bnl-housing']:GetIdentifier(source)
```
Get the player's identifier used in the resource, this case their license. 
 
```lua
exports['bnl-housing']:PlayerName(source)
```
Get the player name used in the resource, if you want you can edit this in the main code (`sv_functions.lua`) to use your desired framework. Later on I will add detection for frameworks.

```lua
exports['bnl-housing']:GetPropertyById(id)
```

```lua
exports['bnl-housing']:GetPropertyPlayerIsInside(source)
```

```lua
exports['bnl-housing']:GetPlayersInsideProperty(property)
```

```lua
exports['bnl-housing']:FindPlayerInProperty(source, property)
```
Check if the given source player is inside of the given property, if so it will return a table of more info used by the resource to specify the player.

```lua
exports['bnl-housing']:UpdatePropertyProp(property, prop)
```
Updates the given prop in given property, it's not really recommended to use this but if you know what you're doing go ahead.

```lua
exports['bnl-housing']:IsPlateInAnyProperty(plate)
```

```lua
exports['bnl-housing']:IsPlateInProperty(plate, property)
```

```lua
exports['bnl-housing']:GetPlayerPropertyPermissionLevel(source, property)
```
Get the permission level the player would have or has in the given property, will return a string with one of the following options: `visitor`, `key_owner`, `owner`.

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Events

These events will be called by this resource. Don't call these yourselfs, just listen for them. These events are all serversided. Again if no description is added they are self explanatory.

```md
 - bnl-housing:server:onPropertiesLoaded
```
Gets called on all properties first loaded, passes all properties as first argument.

```md
 - bnl-housing:event:playerEnteredProperty
```
On player enter property, passes player server-id and property as first and second arguments.

```md
 - bnl-housing:event:playerExitedProperty
```
On player exit property, passes player server-id and property as first and second arguments.

```md
 - bnl-housing:event:playerLoadedInProperty
```
Gets called when a player joins and is in a property, passes player server-id and property as first and second arguments.

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">

## Special Props

This might be a bit hard to show but the idea is that you add a table to [specialprops.lua](./data/specialprops.lua) and add the configuration that you want. For examples you should check [specialprops.lua](./data/specialprops.lua) as I've made props that use every option in there.

*Required* config values:
```lua
-- Max range that the prop functions can be used at. (Also used if you use qtarget)
range = 1.5
```

*Optional* config values:
```lua
-- Text shown with lib.showTextUI
closeText = "Press [E] to perform magic!",

-- Marker that shows above the prop (or bellow if stated in the offset variable)
marker = {
    sprite = 2, -- Sprite of the marker (https://docs.fivem.net/docs/game-references/markers/)
    offset = vector3(0.0, 0.0, 1.25),
    scale = vector3(0.25, 0.25, 0.25),
    rotation = vector3(180.0, 0.0, 0.0),
    color = {
        255, -- Red
        255, -- Green
        255, -- Blue
        255  -- Alpha
    },
    bob = false, -- Make it bob up and down
    faceCamera = true -- Make it face the camera
},

-- Outline given to the prop with the SetEntityDrawOutline native
outline = {
    color = {
        255, -- Red
        255, -- Green
        255, -- Blue
        255  -- Alpha
    },
    shader = 1 -- Shaders: (https://docs.fivem.net/natives/?_0x5261A01A)
},

-- Function executed when pressing E in the specified range.
func = function(prop)
    print("Wow this magic is awesome!")
    print(string.format("Here's the prop id that we've just interacted with: %s", prop.id))
end,

-- Function called on creation of the prop.
onCreate = function(prop)
    print(string.format("Okay boss, I've created prop %s!", prop.id))
    print(string.format("This is it's entity: %s", prop.entity))
end,

-- Function called on removeal of the prop.
onDelete = function(prop)
    print(string.format("Poof! Prop %s is now gone!", prop.id))
end,

-- qtarget support, pass the options in this table. 
--- (I don't know much about qtarget so I hope this is good enough for you who that want to use it.)
qtarget = {
    {
        event = "eventname",
        icon = "fas fa-box-circle-check",
        label = "action 1",
        num = 1
    },
    {
        event = "eventname",
        icon = "fas fa-box-circle-check",
        label = "action 2",
        num = 2
    },
},
```

<img src="https://user-images.githubusercontent.com/60477582/171034076-a15f0d8e-8216-487e-a51a-e01322c316c7.png">