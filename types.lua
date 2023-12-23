---@meta

--[[
    This file is only used for type annotations, no actual code will be written here.
    When adding new functions or variables to classes, make sure to also add them in this file.
]]

---@class Property
---@field id integer
---@field model string
---@field shellData table
---@field entranceLocation vector4
---@field propertyType PropertyType
---@field address Address
---@field bucketId integer
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
---@field entity Entity
---@field saleData table?
---@field rentData table?
---@field destroyModel function
---@field spawnModel function
---@field destroyProps function
---@field spawnProps function
---@field loadProps function
---@field addProp function
---@field removeProp function
---@field loadKeys function
---@field getPlayerKey function
---@field givePlayerKey function
---@field removePlayerKey function
---@field removeAllKeys function
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
---@field loadTransactions function
---@field isForSale function
---@field isForRent function
---@field buy function
---@field rent function
---@field triggerUpdate function
---@field markForSale function
---@field markForRent function

---@class NewPropertyData
---@field location vector4
---@field model string
---@field propertyType string
---@field zipcode string
---@field streetName string
---@field buildingNumber number

---@class Address
---@field zipcode string?
---@field streetName string?
---@field buildingNumber string?

---@class PropertyData
---@field id integer
---@field entranceLocation vector4
---@field location vector3
---@field propertyType PropertyType
---@field address Address
---@field model string
---@field keys table
---@field key? Key
---@field links table
---@field saleData table
---@field isForSale boolean
---@field rentData table
---@field isForRent boolean
---@field props table

---@class Prop
---@field id integer
---@field property Property
---@field model string
---@field location vector3
---@field rotation vector3
---@field metadata table
---@field _metadata table
---@field spawn function
---@field destroy function
---@field getData function
---@field metadataAPI function

---@class PropData
---@field id string
---@field name string
---@field price number

---@class Key
---@field id integer?
---@field propery_id integer
---@field permission Permissions
---@field player string

---@class Player
---@field source integer
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
---@field getMoney function
---@field removeMoney function

---@class Keybind
---@field padIndex integer
---@field control integer
---@field name string

---@class Point
---@field viewDistance number
---@field interact Keybind
---@field marker Marker

---@class Marker
---@field type integer
---@field size vector3
---@field vehicleSize number?
---@field offset vector3
---@field rotation vector3
---@field color table
---@field bob boolean
---@field faceCamera boolean

---@class Outline
---@field color table?
---@field shader number?

---@class Blip
---@field sprite integer
---@field color integer
---@field short boolean?
---@field display integer?
---@field scale number?

---@class PropertyBlips
---@field owner Blip
---@field member Blip
---@field renter Blip
---@field sale Blip

---@class VehicleSlot
---@field id? integer
---@field location vector4

---@class PropMetadataAPI
---@field get fun(key: string)
---@field set fun(key: string, value: any)
---@field clear fun()
---@field getPrivate fun(key: string)
---@field setPrivate fun(key: string, value: any)
---@field clearPrivate fun()

---@alias Entity number

---@alias SpecialPropEventHandler string | table<string>
