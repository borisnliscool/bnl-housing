DB = {}

---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.getAllProperties = function()
    return MySQL.query.await("SELECT * FROM properties")
end

---@param identifier string
---@return table<string, unknown>|nil
DB.getPropertyPlayer = function(identifier)
    return MySQL.single.await(
        "SELECT property_id FROM property_player WHERE player = ?",
        { identifier }
    )
end

---@param identifier string
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.deletePropertyPlayer = function(identifier)
    return MySQL.query.await("DELETE FROM property_player WHERE player = ?", { identifier })
end

---@param propertyId integer
---@param identifier string
---@return number
DB.insertPropertyPlayer = function(propertyId, identifier)
    return MySQL.insert.await(
        "INSERT INTO property_player (property_id, player) VALUES (?, ?)",
        { propertyId, identifier }
    )
end

---@param propertyId integer
---@param model string
---@param location vector4
---@param rotation vector4
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.insertPropertyProp = function(propertyId, model, location, rotation)
    return MySQL.query.await(
        "INSERT INTO property_prop (property_id, model, location, rotation) VALUES (?, ?, ?, ?)", {
            propertyId,
            model,
            json.encode(location),
            json.encode(rotation),
        }
    )
end

---@param propId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.deletePropertyProp = function(propId)
    return MySQL.query.await("DELETE FROM property_prop WHERE id = ?", { propId })
end

---@param propertyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.getPropertyProps = function(propertyId)
    return MySQL.query.await("SELECT * FROM property_prop WHERE property_id = ?", { propertyId })
end

---@param metadata table
---@param propId integer
---@return QueryResult|unknown|{ [number]: { [string]: unknown  }|{ [string]: unknown }|nil}
DB.updatePropertyProp = function(metadata, propId)
    return MySQL.prepare.await("UPDATE property_prop SET metadata = ? WHERE id = ?", {
        json.encode(metadata),
        propId
    })
end

---@param propertyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.getPropertyKeys = function(propertyId)
    return MySQL.query.await("SELECT * FROM property_key WHERE property_id = ?", { propertyId })
end

---@param propertyId integer
---@param player string
---@param permission Permissions
---@return number
DB.insertPropertyKey = function(propertyId, player, permission)
    return MySQL.insert.await("INSERT INTO property_key (property_id, player, permission) VALUES (?, ?, ?)", {
        propertyId,
        player,
        permission
    })
end

---@param keyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.removePropertyKey = function(keyId)
    return MySQL.query.await("DELETE FROM property_key WHERE id = ?", { keyId })
end

---@param propertyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.removePropertyKeys = function(propertyId)
    return MySQL.query.await("DELETE FROM property_key WHERE property_id = ?", { propertyId })
end

---@param propertyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.getPropertyVehicles = function(propertyId)
    return MySQL.query.await("SELECT * FROM property_vehicle WHERE property_id = ?", { propertyId })
end

---@param propertyId integer
---@param slotId integer
---@param vehicleProps table
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.insertPropertyVehicle = function(propertyId, slotId, vehicleProps)
    return MySQL.query.await("INSERT INTO property_vehicle (property_id, slot, props) VALUES (?, ?, ?)", {
        propertyId,
        slotId,
        json.encode(vehicleProps)
    })
end

---@param propertId integer
---@param slotId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.removePropertyVehicle = function(propertId, slotId)
    return MySQL.query.await("DELETE FROM property_vehicle WHERE property_id = ? AND slot = ?", {
        propertId,
        slotId
    })
end

---@param propertyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.getPropertyLinks = function(propertyId)
    local query = [[
        SELECT linked_property_id AS property_id FROM property_link WHERE property_id = ? UNION
        SELECT property_id AS property_id FROM property_link WHERE linked_property_id = ?
    ]]

    return MySQL.query.await(query, { propertyId, propertyId })
end

---@param propertyId integer
---@return QueryResult|{ [number]: { [string]: unknown  }}
DB.getPropertyTransactions = function(propertyId)
    return MySQL.query.await(
        "SELECT * FROM property_transaction WHERE property_id = ? AND transaction_type IN ('rental', 'sale') ORDER BY start_date DESC LIMIT 2;",
        { propertyId }
    )
end

---@param playerIdentifier string
---@param completionStatus CompletionStatus
---@param transactionId integer
DB.updatePropertyTransaction = function(playerIdentifier, completionStatus, transactionId)
    MySQL.query.await("UPDATE property_transaction SET customer = ?, status = ? WHERE id = ?", {
        playerIdentifier,
        completionStatus,
        transactionId
    })
end

---@param playerIdentifier string
---@param propertyId integer
---@param price number
---@param transactionType TransactionType
---@param paymentInterval? string
---@return number
DB.insertPropertyPayment = function(playerIdentifier, propertyId, price, transactionType, paymentInterval)
    return MySQL.insert.await(
    "INSERT INTO property_payments (player, property_id, amount, payment_type, payment_interval) VALUES (?, ?, ?, ?, ?)",
        {
            playerIdentifier,
            propertyId,
            price,
            transactionType,
            paymentInterval
        })
end
