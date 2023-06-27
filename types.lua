--[[
    This file is only used for type annotations, no actual code will be written here.
    When adding new functions or variables to classes, make sure to also add them in this file.
]]

---@class Property
---@field id number
---@field model string
---@field shellData table
---@field entranceLocation vector4
---@field propertyType PropertyType
---@field address Address
---@field bucketId number
---@field props table
---@field keys table
---@field links table
---@field players table
---@field vehicles table
---@field isSpawning boolean
---@field isSpawned boolean
---@field isSpawningVehicles boolean
---@field vehiclesSpawned boolean
---@field location vector3
---@field entity number
---@field destroyModel function
---@field spawnModel function
---@field destroyProps function
---@field spawnProps function
---@field loadProps function
---@field loadKeys function
---@field getPlayerKey function
---@field givePlayerKey function
---@field removePlayerKey function
---@field loadVehicleData function
---@field spawnVehicle function
---@field spawnVehicles function
---@field spawnOutsideVehicle function
---@field destroyVehicles function
---@field getFirstFreeVehicleSlot function
---@field enter function
---@field exit function
---@field loadLinks function
---@field getPlayer function
---@field isPlayerInside function
---@field save function
---@field destroy function
---@field getData function
---@field getOutsidePlayers function
---@field knock function

---@class Address
---@field zipcode string
---@field streetName string
---@field buildingNumber string

---@class PropertyData
---@field id number
---@field entranceLocation vector4
---@field location vector3
---@field propertyType PropertyType
---@field address Address
---@field model string
---@field keys table
---@field links table

---@class Prop
---@field id number
---@field property Property
---@field model string
---@field location vector3
---@field rotation vector3
---@field metadata table
---@field spawn function
---@field destroy function

---@class Key
---@field id number | nil
---@field propery_id number
---@field permission Permissions
---@field player string

---@class Player
---@field source number
---@field identifier string
---@field name string
---@field property Property
---@field key table
---@field setBucket function
---@field ped function
---@field vehicle function
---@field warpIntoProperty function
---@field warpOutOfProperty function
---@field triggerFunction function
---@field freeze function

---@class Keybind
---@field padIndex number
---@field control number
---@field name string

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

---@class VehicleSlot
---@field location vector4

---@alias Entity number