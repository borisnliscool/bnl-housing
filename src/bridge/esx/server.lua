local ESX = exports['es_extended']:getSharedObject()

function Bridge.GetPlayerIdentifier(source)
    return ESX.GetPlayerFromId(source).getIdentifier()
end
