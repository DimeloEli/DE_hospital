local spawnedPeds = {}

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
			lib.progressCircle({ label = 'Checking in', duration = Config.CheckInTimer * 1000, position = 'bottom', useWhileDead = false, canCancel = true, anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base' }, prop = { model = 'p_amb_clipboard_01', bone = 18905, pos = { x = 0.10, y = 0.02, z = 0.08 }, rot = { x = -80.0, y = 0.0, z = 0.0 }, disable = { move = true, car = true, mouse = false, combat = true, sprint = true } } })
			TriggerServerEvent('DE_hospital:RequestBed')
		end
	end)
end)

RegisterNetEvent('DE_hospital:hospitalbed')
AddEventHandler('DE_hospital:hospitalbed', function(id, coords)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)
	
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
	lib.progressCircle({ label = 'Being healed', duration = Config.HealingTimer * 1000, position = 'bottom', useWhileDead = false, canCancel = false, disable = { move = true, car = true, combat = true, mouse = false, sprint = true }})
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

	exports.ox_target:addLocalEntity(spawnedPed, {
		label = 'Check-in',
		icon = 'fas fa-kit-medical',
		distance = 3.0,
		event = 'DE_hospital:checkin'
	})

	return spawnedPed
end