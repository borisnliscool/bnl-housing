---@class Interact
---@field interactMode "walk" | "keypress" | "target"
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
        Debug.Log(Format("Special prop handler %s already exists, overwriting.", options.model))
    end

    ClientSpecialProps[options.model] = options
    Debug.Log(Format("Registered special prop handler for %s", options.model))
end

exports("registerSpecialProp", handler)

---

local specialPropPoints = {}

RegisterNetEvent("bnl-housing:on:enterProperty", function(propertyId)
    local property = Properties[propertyId]
    if not property then return end

    for _, prop in ipairs(property.props) do
        local data = ClientSpecialProps[prop.model]
        if not data then
            goto continue
        end

        prop.entity = NetworkGetEntityFromNetworkId(
            lib.callback.await(
                "bnl-housing:server:property:decoration:getPropEntity", false, CurrentProperty.id, prop.id
            )
        )

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
                data.interact.interactMode == "walk" or
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
                            prop
                        )

                        -- trigger server event here
                    end
                end

                function point:onEnter()
                    if data.interact.outline then
                        SetEntityDrawOutline(prop.entity, true)

                        if data.interact.outline.color then
                            SetEntityDrawOutlineColor(
                                data.interact.outline.color.r,
                                data.interact.outline.color.g,
                                data.interact.outline.color.b,
                                data.interact.outline.color.a
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
        end

        ::continue::
    end
end)

RegisterNetEvent("bnl-housing:on:leaveProperty", function(propertyId)
    local property = Properties[propertyId]
    if not property then return end

    for _, prop in ipairs(property.props) do
        if not ClientSpecialProps[prop.model] then
            goto continue
        end

        CallSpecialPropHandlers(
            ClientSpecialProps[prop.model].handlers?.client?.destroy,
            prop
        )

        for _, point in ipairs(specialPropPoints) do
            point:remove()
            specialPropPoints[_] = nil
        end

        ::continue::
    end
end)
