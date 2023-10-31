function StartRentCronJobs()
    for _, payment in pairs(DB.getPropertyRentPayments()) do
        lib.cron.new(payment.payment_interval, function()
            local property = GetPropertyById(payment.property_id)
            if not property then return end

            -- todo
            -- if player cannot afford, remove key and reset availability

            Bridge.RemoveMoney(payment.player, payment.amount)

            if Bridge.GetServerIdFromIdentifier(payment.player) then
                ClientFunctions.Notification(
                    Bridge.GetServerIdFromIdentifier(payment.player),
                    locale(
                        "notification.rent.paid", payment.amount, property.address.streetName,
                        property.address.buildingNumber
                    )
                )
            end

            local ownerKey = table.findOne(property.keys, function(key)
                return key.permission == PERMISSION.OWNER
            end) --[[@as Key]]
            if not ownerKey then return end

            Bridge.AddMoney(ownerKey.player, payment.amount)
        end)
    end
end
