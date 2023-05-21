local beds = {}
local takenBeds = {}

AddEventHandler('onResourceStart', function (resourceName)
	if (GetCurrentResourceName() == resourceName) then
		for k, v in pairs(Config.BedCoords) do
			table.insert(beds, {coords = v, taken = false})
		end
	end
end)

AddEventHandler('onResourceStop', function (resourceName)
	if (GetCurrentResourceName() == resourceName) then
        for k, v in pairs(beds) do
            if v.taken then
                v.taken = false
            end
        end
	end
end)

AddEventHandler('playerDropped', function (resourceName)
    if takenBeds[source] ~= nil then
        beds[takenBeds[source]].taken = false
    end
end)

RegisterServerEvent('DE_hospital:RequestBed')
AddEventHandler('DE_hospital:RequestBed', function()
    for k, v in pairs(beds) do
        if not v.taken then
            v.taken = true
            takenBeds[source] = k
            TriggerClientEvent('DE_hospital:hospitalbed', source, k, v.coords)
            return
        end
    end
end)

RegisterServerEvent('DE_hospital:finishHeal')
AddEventHandler('DE_hospital:finishHeal', function(id)
    beds[id].taken = false
end)

ESX.RegisterServerCallback('DE_hospital:checkMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getAccount('money').money >= Config.CheckInPrice then
        xPlayer.removeInventoryItem('money', Config.CheckInPrice)
        cb(true)
    else
        cb(false)
        Notify(source, 'error', 'You don\'t have enough money for this.')
    end
end)