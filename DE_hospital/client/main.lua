local spawnedPeds, clipboardObj, pencilObj = {}, nil, nil

for k, v in pairs(Config.CheckIn) do
    exports['qtarget']:AddBoxZone(v.name, vector3(v.coords.xyz), 3.6, 2.8, {
        name= v.name,
        heading= 90.22,
        debugPoly= false,
        minZ= v.coords.z,
        maxZ= v.coords.z + 2.8,
        }, {
        options = {
            {
                event = 'DE_hospital:checkin',
                icon = "fas fa-kit-medical",
                label = "Check-in",
            },
        },
        distance = 3.5
    })
end

CreateThread(function()
	while true do
		Wait(500)
		for k,v in pairs(Config.CheckIn) do
			local playerCoords = GetEntityCoords(PlayerPedId())
			local distance = #(playerCoords - v.coords.xyz)

			if distance < Config.PedDist and not spawnedPeds[k] then
				local spawnedPed = NearPed(v.ped, v.coords, v.animDict, v.animName, v.scenario)
				spawnedPeds[k] = { spawnedPed = spawnedPed }
			end

			if distance >= Config.PedDist and spawnedPeds[k] then
				if Config.FadeIn then
					for i = 255, 0, -51 do
						Wait(50)
						SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
					end
				end
				DeletePed(spawnedPeds[k].spawnedPed)
				spawnedPeds[k] = nil
			end
		end
	end
end)

RegisterNetEvent('DE_hospital:checkin')
AddEventHandler('DE_hospital:checkin', function()
	local playerPed = PlayerPedId()

	ESX.TriggerServerCallback('DE_hospital:checkMoney', function(hasMoney)
		if hasMoney then
			clipboardObj = CreateObject(GetHashKey('p_amb_clipboard_01'), 0, 0, 0, true, true, true)
			pencilObj = CreateObject(GetHashKey('prop_pencil_01'), 0, 0, 0, true, true, true)

			AttachEntityToEntity(clipboardObj, playerPed, GetPedBoneIndex(playerPed, 18905), 0.10, 0.02, 0.08, -80.0, 0.0, 0.0, true, true, false, true, 1, true)
			AttachEntityToEntity(pencilObj, playerPed, GetPedBoneIndex(playerPed, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true)
			ESX.Streaming.RequestAnimDict('missheistdockssetup1clipboard@base', function()
        		TaskPlayAnim(playerPed, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8, -1, 49, 0, false, false, false)
   	 		end)
			exports.rprogress:Start('Checking in...', Config.CheckInTimer * 1000)

			ClearPedTasks(playerPed)
			DeleteObject(clipboardObj)
			DeleteObject(pencilObj)
			clipboardObj = nil
			pencilObj = nil

			TriggerServerEvent('DE_hospital:RequestBed')
		end
	end)
end)

RegisterNetEvent('DE_hospital:hospitalbed')
AddEventHandler('DE_hospital:hospitalbed', function(id, coords)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed) - 100
	
	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Citizen.Wait(50)
	end

	SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
	SetEntityHeading(playerPed, coords.w)
	ESX.Streaming.RequestAnimDict('anim@gangops@morgue@table@', function()
		TaskPlayAnim(playerPed, 'anim@gangops@morgue@table@', 'body_search', 8.0, -8, -1, 1, 0, false, false, false)
	end)
	DoScreenFadeIn(800)
	exports.rprogress:Start('Being healed...', Config.HealingTimer * 1000)
	TriggerServerEvent('DE_hospital:finishHeal', id)
	ClearPedTasks(playerPed)
	SetEntityCoords(playerPed, Config.RespawnCoords.x, Config.RespawnCoords.y, Config.RespawnCoords.z, false, false, false, true)
	SetEntityHeading(playerPed, Config.RespawnCoords.w)
	SetEntityHealth(playerPed, maxHealth)
	Notify('inform', 'You have payed $' .. Config.CheckInPrice .. ' and have been healed')
end)

NearPed = function(model, coords, animDict, animName, scenario)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(50)
	end

	spawnedPed = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)

	SetEntityAlpha(spawnedPed, 0, false)
	FreezeEntityPosition(spawnedPed, true)
	SetEntityInvincible(spawnedPed, true)
	SetBlockingOfNonTemporaryEvents(spawnedPed, true)

	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Wait(50)
		end

		TaskPlayAnim(spawnedPed, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end

    if scenario then
        TaskStartScenarioInPlace(spawnedPed, scenario, 0, true)
    end

	for i = 0, 255, 51 do
		Wait(50)
		SetEntityAlpha(spawnedPed, i, false)
	end

	return spawnedPed
end