---@class Interact
---@field interactMode "keypress" | "target"
---@field keybind Keybind?
---@field target OxTargetOption?
---@field range number
---@field marker Marker?
---@field outline Outline?
---@field helpText string?

---@class ClientHandlers
---@field interact SpecialPropEventHandler?
---@field spawn SpecialPropEventHandler?
---@field destroy SpecialPropEventHandler?

---@class SpecialPropClientHandlerOptions
---@field model string
---@field interact Interact?
---@field handlers { client: ClientHandlers }?

---@type table<string, SpecialPropClientHandlerOptions>
ClientSpecialProps = {}

---@param options SpecialPropClientHandlerOptions
local handler = function(options)
    if ClientSpecialProps[options.model] then
        lib.print.warn(("Special prop handler %s already exists, overwriting."):format(options.model))
    end

    ClientSpecialProps[options.model] = options
    lib.print.info(("Registered special prop handler for %s"):format(options.model))
end

exports("registerSpecialProp", handler)

---

local specialPropPoints = {}

RegisterNetEvent("bnl-housing:on:enterProperty", function(propertyId)
    local property = Properties[propertyId]
    if not property then return end

    for _, prop in pairs(property.props) do
        local data = ClientSpecialProps[prop.model]
        if not data then
            goto continue
        end

        local propNetId = lib.callback.await(
            "bnl-housing:server:property:decoration:getPropEntity", false, CurrentProperty.id, prop.id
        )
        prop.entity = NetworkGetEntityFromNetworkId(propNetId)

        CallSpecialPropHandlers(
            data.handlers?.client?.spawn,
            prop
        )

        -- todo extract to function
        if data.interact then
            local globalPropLocation = vector3(
                property.location.x + prop.location.x,
                property.location.y + prop.location.y,
                property.location.z + prop.location.z
            )

            if
                data.interact.interactMode == "keypress" or
                data.interact.marker or
                data.interact.outline or
                data.interact.helpText
            then
                local point = lib.points.new({
                    coords = globalPropLocation,
                    distance = data.interact.range
                })

                function point:nearby()
                    if data.interact.helpText then
                        ShowHelpNotification(data.interact.helpText)
                    end

                    local markerData = data.interact.marker
                    if markerData then
                        DrawMarker(
                            markerData.type,
                            globalPropLocation.x + markerData.offset.x,
                            globalPropLocation.y + markerData.offset.y,
                            globalPropLocation.z + markerData.offset.z,
                            0.0, 0.0, 0.0,
                            (markerData.rotation and markerData.rotation.x ~= nil) and markerData.rotation.x or 0.0,
                            (markerData.rotation and markerData.rotation.y ~= nil) and markerData.rotation.y or 0.0,
                            (markerData.rotation and markerData.rotation.z ~= nil) and markerData.rotation.z or 0.0,
                            (markerData.size and markerData.size.x ~= nil) and markerData.size.x or 1.0,
                            (markerData.size and markerData.size.y ~= nil) and markerData.size.y or 1.0,
                            (markerData.size and markerData.size.z ~= nil) and markerData.size.z or 1.0,
                            (markerData.color and markerData.color.r ~= nil) and markerData.color.r or 255,
                            (markerData.color and markerData.color.g ~= nil) and markerData.color.g or 255,
                            (markerData.color and markerData.color.b ~= nil) and markerData.color.b or 255,
                            (markerData.color and markerData.color.a ~= nil) and markerData.color.a or 255,
                            markerData.bob ~= nil and markerData.bob or false,
                            markerData.faceCamera ~= nil and markerData.faceCamera or false,
                            ---@diagnostic disable-next-line: param-type-mismatch
                            2, false, nil, nil, false
                        )
                    end

                    if
                        data.interact.keybind and
                        IsControlJustPressed(data.interact.keybind.padIndex, data.interact.keybind.control)
                    then
                        CallSpecialPropHandlers(
                            data.handlers?.client?.interact,
                            -- Find the prop because it could be updated by property:setData
                            table.findOne(property.props, function(value)
                                return value.id == prop.id
                            end)
                        )

                        TriggerServerEvent("bnl-housing:server:specialprops:interact", property.id, prop.id)
                    end
                end

                function point:onEnter()
                    if data.interact.outline then
                        SetEntityDrawOutline(prop.entity, true)

                        if data.interact.outline.color then
                            SetEntityDrawOutlineColor(
                                (data.interact.outline.color.r and data.interact.outline.color.r or 255),
                                (data.interact.outline.color.g and data.interact.outline.color.g or 255),
                                (data.interact.outline.color.b and data.interact.outline.color.b or 255),
                                (data.interact.outline.color.a and data.interact.outline.color.a or 255)
                            )
                        end

                        if data.interact.outline.shader then
                            SetEntityDrawOutlineShader(data.interact.outline.shader)
                        end
                    end
                end

                function point:onExit()
                    if data.interact.outline then
                        SetEntityDrawOutline(prop.entity, false)
                    end
                end

                table.insert(specialPropPoints, point)
            end

            if data.interact.interactMode == "target" and data.interact.target then
                for _, option in pairs(data.interact.target) do
                    option.distance = data.interact.range

                    local _select = option.onSelect
                    if _select then
                        option.onSelect = function(...)
                            ---@diagnostic disable-next-line: redundant-parameter
                            _select(..., prop)
                        end
                    end
                end

                exports.ox_target:addEntity(propNetId, data.interact.target)
            end
        end

        ::continue::
    end
end)

RegisterNetEvent("bnl-housing:on:leaveProperty", function(propertyId)
    local property = Properties[propertyId]
    if not property then return end

    for _, prop in ipairs(property.props) do
        local data = ClientSpecialProps[prop.model]
        if not data then
            goto continue
        end

        CallSpecialPropHandlers(
            data.handlers?.client?.destroy,
            prop
        )

        for _, point in pairs(specialPropPoints) do
            point:remove()
            specialPropPoints[_] = nil
        end

        if data.interact?.interactMode == "target" then
            exports.ox_target:removeEntity(NetworkGetNetworkIdFromEntity(prop.entity))
        end

        ::continue::
    end
end)
