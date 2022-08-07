function Play3DSound(sound, distance)
	SendNUIMessage({
		type = 'playSound',
		soundFile = sound,
		distance = distance
	})
end

function HelpNotification(message, duration)
	SetTextComponentFormat("STRING")
	AddTextComponentString(message)
	DisplayHelpTextFromStringLabel(0, 0, 1, duration or - 1)
end

RegisterNetEvent("bnl-housing:setClipboard", function(data)
    lib.setClipboard(data)
end)