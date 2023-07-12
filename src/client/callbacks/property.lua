lib.callback.register("bnl-housing:client:updateProperty", function(propertyId, propertyData)
    Properties[propertyId]:setData(propertyData)
end)
