function StartRentCronJobs()
    for _, payment in pairs(DB.getPropertyRentPayments()) do
        print(json.encode(payment, { indent = true }))

        lib.cron.new(payment.payment_interval, function()
            Bridge.RemoveMoney(payment.player, payment.amount)

            -- todo:
            --  notification to the player if they are online

            local property = GetPropertyById(payment.property_id)
            if not property then return end

            local ownerKey = table.findOne(property.keys, function(key)
                return key.permission == PERMISSION.OWNER
            end) --[[@as Key]]
            if not ownerKey then return end

            Bridge.AddMoney(ownerKey.player, payment.amount)
        end)
    end
end
