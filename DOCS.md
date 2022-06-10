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