return {
	["prop_ld_int_safe_01"] = {
		closeText = "Press [E] to open the safe",
		marker = {
			sprite = 2,
			offset = vector3(0.0, 0.0, 1.25),
			scale = vector3(0.25, 0.25, 0.25),
			rotation = vector3(180.0, 0.0, 0.0),
			color = {
				255,
				255,
				255,
				255
			},
			bob = false,
			faceCamera = true
		},
		outline = {
			color = {
				255,
				255,
				255,
				255
			},
			shader = 1
		},
		range = 1.5,
		func = function(prop)
			local prop = GetPropertyPropById(propertyPlayerIsIn, prop.id)
			if (currentPropertyPermissionLevel == 'owner') then
				lib.registerContext({
					id = 'property_safe_menu',
					title = locale('property') .. ' ' .. locale('safe'),
					options = {
						{
							title = locale('open_safe'),
							event = 'bnl-housing:client:openSafe',
							args = {
								prop = prop
							}
						},
						{
							title = locale('set_safe_code'),
							event = 'bnl-housing:client:setSafeCode',
							args = {
								prop = prop
							}
						},
					}
				})
				lib.showContext('property_safe_menu')
			else
				OpenSafeWithCode({
					prop = prop
				})
			end
		end,
        onCreate = function(prop)
            Logger.Success('Spawned safe prop:', prop)
        end,
        onDelete = function(prop)
            Logger.Success('Deleted safe prop:', prop)
        end
	},
	["prop_tool_bench02_ld"] = {
		closeText = "Press [E] to open the workbench",
		marker = {
			sprite = 2,
			offset = vector3(0.0, 0.0, 1.25),
			scale = vector3(0.25, 0.25, 0.25),
			rotation = vector3(180.0, 0.0, 0.0),
			color = {
				255,
				255,
				255,
				255
			},
			bob = false,
			faceCamera = true
		},
		range = 1.5,
		func = function(prop)
			-- Here you can do whatever you want, for example calling a exports
			Logger.Success(prop)
		end
	},
	["example"] = {
		qTarget = {
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
		range = 1.5,
		marker = {
			sprite = 2,
			offset = vector3(0.0, 0.0, 1.25),
			scale = vector3(0.25, 0.25, 0.25),
			rotation = vector3(180.0, 0.0, 0.0),
			color = {
				255,
				255,
				255,
				255
			},
			bob = false,
			faceCamera = true
		},
		outline = {
			color = {
				255,
				255,
				255,
				255
			},
			shader = 1
		},
	}
}
