RMenu.Add("popo_ammu", "menu", RageUI.CreateMenu(_U('ammu'), "~b~".._U('categorie')))
RMenu:Get("popo_ammu", "menu").Closed = function()
end

RMenu.Add("popo_ammu", "stock", RageUI.CreateMenu("Stock", "Stock"))
RMenu:Get("popo_ammu", "stock").Closed = function()
end

RMenu.Add("popo_ammu", "ppa", RageUI.CreateSubMenu(RMenu:Get("popo_ammu", "menu"), "PPA", nil))
RMenu:Get("popo_ammu", "ppa").Closed = function()end

RMenu.Add("popo_ammu", "announce", RageUI.CreateSubMenu(RMenu:Get("popo_ammu", "menu"), _U('announce'), nil))
RMenu:Get("popo_ammu", "announce").Closed = function()end

RMenu.Add("popo_ammu", "accueil", RageUI.CreateMenu("Ammunation", "~b~Accueil"))
RMenu:Get("popo_ammu", "accueil").Closed = function()
end

RMenu.Add("popo_ammu", "rdv", RageUI.CreateSubMenu(RMenu:Get("popo_ammu", "accueil"), "RDV", nil))
RMenu:Get("popo_ammu", "rdv").Closed = function()end

RMenu.Add("popo_ammu", "garage", RageUI.CreateMenu("Ammunation", "~b~Garage"))
RMenu:Get("popo_ammu", "garage").Closed = function()
end

local vehicle = nil
local nomprenom = nil
local num = nil
local motif = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10000)
    end
    if ESX.IsPlayerLoaded() then
		ESX.PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
	AddTextEntry(entryTitle, textEntry)
	DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
  blockinput = true
  
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
  
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
	blockinput = false
		return result
	else
		Citizen.Wait(500)
	blockinput = false
		return nil
	end
  end

--open the stock menu in RageUI--
local function openStockMenu()
	RageUI.Visible(RMenu:Get("popo_ammu","stock"), true)
	Citizen.CreateThread(function()
		while true do
			RageUI.IsVisible(RMenu:Get("popo_ammu","stock"),true,true,true,function()
				RageUI.Button(_U('get_stock'), _U('get_stock'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                    if (s) then
						RageUI.CloseAll()
						OpenGetStocksMenu()
                    end
                end)
				RageUI.Button(_U('put_stock'), _U('put_stock'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
                    if (s) then
						RageUI.CloseAll()
						OpenPutStocksMenu()
                    end
                end)
			end, function()end)
			Citizen.Wait(0)
		end
	end)
end

--open the boss menu in RageUI--
local function openBossMenu()
	TriggerEvent('esx_society:openBossMenu', 'ammu', function(data, menu)
		menu.close()
	end)
end

local function facture()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
		title =  _U('name_billing')
	}, function(data, menu)

		local amount = tonumber(data.value)

		if amount == nil or amount <= 0 then
			ESX.ShowNotification("Montant invalide")
		else
			menu.close()

			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if closestPlayer == -1 or closestDistance > 3.0 then
				ESX.ShowNotification("Pas de joueur")
			else
				local playerPed        = GetPlayerPed(-1)

				Citizen.CreateThread(function()
					TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
					Citizen.Wait(5000)
					ClearPedTasks(playerPed)
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_ammu', 'Ammunation', amount)
				end)
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end

--open the F6 menu in RageUI--
local function openAmmuMenu()

	RageUI.Visible(RMenu:Get("popo_ammu","menu"), true)
	Citizen.CreateThread(function()
		while true do
			local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
			local playerserverid = GetPlayerServerId(closestPlayer)
			local closestPlayerPed = GetPlayerPed(closestPlayer)
      		--ESX.ShowNotification("INTENTANDO CARGAR2 A: ".. GetPlayerName(ESX.Game.GetClosestPlayer()) .. " Estado: " .. tostring(IsPedDeadOrDying(closestPlayerPed)))
			RageUI.IsVisible(RMenu:Get("popo_ammu","menu"),true,true,true,function()
                RageUI.Button("PPA", "PPA", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
					end
                end, RMenu:Get("popo_ammu", "ppa"))
				RageUI.Button(_U('billing'), _U('billing'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						RageUI.CloseAll()
						facture()
					end
                end)
				RageUI.Button(_U('announce'), _U('announce'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
					end
				end, RMenu:Get("popo_ammu", "announce"))
            end, function()end)
			RageUI.IsVisible(RMenu:Get("popo_ammu","announce"),true,true,true,function()
				RageUI.Button(_U('open_ammu'), _U('open_ammu'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						TriggerServerEvent('p0p0_ammu:open')
					end
                end)
				RageUI.Button(_U('close_ammu'), _U('close_ammu'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						TriggerServerEvent('p0p0_ammu:close')
					end
                end)
				RageUI.Button(_U('recruit_ammu'), _U('recruit_ammu'), {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						TriggerServerEvent('p0p0_ammu:recrutement')
					end
                end)
			end, function()end)
			RageUI.IsVisible(RMenu:Get("popo_ammu","ppa"),true,true,true,function()
				RageUI.Button("Donner le PPA", "Donner le PPA", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						ESX.ShowNotification("Donner le PPA")
					end
                end)
				RageUI.Button("Retirer le PPA", "Retirer le PPA", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						ESX.ShowNotification("Confisquer le PPA")
					end
                end)
			end, function()end)
			Citizen.Wait(0)
		end
	end)
end

--boss marker--
Citizen.CreateThread(function()
    while true do
		local interval = 1
        Citizen.Wait(interval)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ammu' and ESX.PlayerData.job.grade_name == 'boss' then 

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.bosspos)
            if dist <= 15.0 then
			interval = 200
            DrawMarker(20, Config.bosspos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
            end
			interval = 1
            if dist <= 1.0 then
                	AddTextEntry("try", _U('open'))
					DisplayHelpTextThisFrame("try", false)
                if IsControlJustPressed(1,51) then
                    openBossMenu()
                end
            end
        end
    end
end)

--stock marker--
Citizen.CreateThread(function()
    while true do
		local interval = 1
        Citizen.Wait(interval)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ammu' then 

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.stockpos)
            if dist <= 15.0 then
			interval = 200
            DrawMarker(20, Config.stockpos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
            end
			interval = 1
            if dist <= 1.0 then
                	AddTextEntry("stock", _U('open_stock'))
					DisplayHelpTextThisFrame("stock", false)
                if IsControlJustPressed(1,51) then
                    openStockMenu()
                end
            end
        end
    end
end)

--F6 pressed ?--
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ammu' then 
			if IsControlJustReleased(0 ,167) then
				openAmmuMenu()
			end
		end
	end
end)

function OpenGetStocksMenu()

	ESX.TriggerServerCallback('popo_ammu_job:getStockItems', function(items)

		print(json.encode(items))

		local elements = {}

		for i=1, #items, 1 do
			if (items[i].count ~= 0) then
				table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
				title    = 'ammu News Stock',
				align    = 'top-left',
				elements = elements
			}, function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
						title = _U('quantity')
					}, function(data2, menu2)
		
						local count = tonumber(data2.value)

						if count == nil or count <= 0 then
							ESX.ShowNotification(_U('invalid_quantity'))
						else
							menu2.close()
							menu.close()
							OpenGetStocksMenu()

							TriggerServerEvent('popo_ammu_job:getStockItems', itemName, count)
						end
					end, function(data2, menu2)
						menu2.close()
					end)
			end, function(data, menu)
				menu.close()
			end)
	end)
end

function OpenPutStocksMenu()

	ESX.TriggerServerCallback('popo_ammu_job:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do

			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
				title    = _U('inventory'),
				elements = elements
			}, function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
						title = _U('quantity')
					}, function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil or count <= 0 then
							ESX.ShowNotification(_U('invalid_quantity'))
						else
							menu2.close()
							menu.close()
							OpenPutStocksMenu()

							TriggerServerEvent('popo_ammu_job:putStockItems', itemName, count)
						end
					end, function(data2, menu2)
						menu2.close()
					end)
			end, function(data, menu)
				menu.close()
			end)
	end)
end

--Menu RageUI 3 véhicule--

local function openGarageMEnu()
	RageUI.Visible(RMenu:Get("popo_ammu","garage"), true)
	Citizen.CreateThread(function()
		while true do
			RageUI.IsVisible(RMenu:Get("popo_ammu","garage"),true,true,true,function()
                RageUI.Button("Van", "Van", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						RageUI.CloseAll()
						local model = GetHashKey("aboxville")
                    	RequestModel(model)
                    	while not HasModelLoaded(model) do
							RequestModel(model)
							Citizen.Wait(10)
						end
                    	vehicle = CreateVehicle(model, 822.0640, -2139.5156, 29.09, 1.1968, true, true)
						SetEntityAsMissionEntity(vehicle, true, true)
						SetVehicleNumberPlateText(vehicle, "AMMU")
					end
                end)
				RageUI.Button('Cammionette', "Cammionette", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						RageUI.CloseAll()
						local model = GetHashKey("aburrito")
                    	RequestModel(model)
                    	while not HasModelLoaded(model) do
							RequestModel(model)
							Citizen.Wait(10)
						end
                    	vehicle = CreateVehicle(model, 822.0640, -2139.5156, 29.09, 1.1968, true, true)
						SetEntityAsMissionEntity(vehicle, true, true)
						SetVehicleNumberPlateText(vehicle, "AMMU")
					end
                end)
				RageUI.Button("blindé", "blindé", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						RageUI.CloseAll()
						local model = GetHashKey("astockade")
                    	RequestModel(model)
                    	while not HasModelLoaded(model) do
							RequestModel(model)
							Citizen.Wait(10)
						end
                    	vehicle = CreateVehicle(model, 822.0640, -2139.5156, 29.09, 1.1968, true, true)
						SetEntityAsMissionEntity(vehicle, true, true)
						SetVehicleNumberPlateText(vehicle, "AMMU")
					end
				end)
            end, function()end)
			Citizen.Wait(0)
		end
	end)
end

--garage marker--
Citizen.CreateThread(function()
    while true do
		local interval = 1
        Citizen.Wait(interval)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ammu' then 

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.garage_pos)
            if dist <= 1.0 then
			interval = 200
            DrawMarker(20, Config.garage_pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
            end
			interval = 1
            if dist <= 1.0 then
                	AddTextEntry("garage", _U('open_garage'))
					DisplayHelpTextThisFrame("garage", false)
                if IsControlJustPressed(1,51) then
					openGarageMEnu()
                end
            end
        end
    end
end)

--garage suppr marker--
Citizen.CreateThread(function()
    while true do
		local interval = 1
        Citizen.Wait(interval)
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ammu' then 

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.garagesuppr_pos)
            if dist <= 1.0 then
			interval = 200
            DrawMarker(20, Config.garagesuppr_pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
            end
			interval = 1
            if dist <= 1.0 then
                	AddTextEntry("garagesuppr", _U('close_garage'))
					DisplayHelpTextThisFrame("garagesuppr", false)
                if IsControlJustPressed(1,51) then
					DeleteVehicle(vehicle)
    				FreezeEntityPosition(PlayerPedId(), false)
                end
            end
        end
    end
end)

--open the secretariat menu in RageUI--
local function openrdvMenu()
	RageUI.Visible(RMenu:Get("popo_ammu","accueil"), true)
	Citizen.CreateThread(function()
		while true do
			RageUI.IsVisible(RMenu:Get("popo_ammu","accueil"),true,true,true,function()
				RageUI.Button("Appeller un vendeur", "Appeller un vendeur", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						TriggerServerEvent('p0p0_ammu:appel')
					end
				end)
				RageUI.Button("Prendre Rendez-vous", "Prendre Rendez-vous", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
					end
				end, RMenu:Get("popo_ammu", "rdv"))
			end, function()end)
			RageUI.IsVisible(RMenu:Get("popo_ammu","rdv"),true,true,true,function()
				RageUI.Button("Prénom et Nom", "Prénom et Nom", {RightLabel = nomprenom}, true,function(h,a,s)
					if (s) then
						local name = KeyboardInput("POPO_BOX_NAME","Prénom et Nom", "", 150)
						if name and name ~= "" then
							nomprenom = tostring(name)
						end
						name = nil
					end
				end)
				RageUI.Button("Numéro de téléphone", "Numéro de téléphone", {RightLabel = num}, true,function(h,a,s)
					if (s) then
						local name = KeyboardInput("POPO_BOX_NUM", "Numéro de téléphone", "", 150)
						if name and name ~= "" then
							num = tostring(name)
						end
						name = nil
					end
				end)
				RageUI.Button("Motif du Rendez-vous", "Motif du Rendez-vous", {RightLabel = motif}, true,function(h,a,s)
					if (s) then
						local name = KeyboardInput("POPO_BOX_MOTIF", _U('name'), "", 150)
						if name and name ~= "" then
							motif = tostring(name)
						end
						name = nil
					end
				end)
				RageUI.Button("Valider la demande", "Valider la demande", {RightLabel = "~g~>>>"}, true,function(h,a,s)
					if (s) then
						if motif == nil or num == nil or nomprenom == nil then
							ESX.ShowNotification("~r~Il nous manque des informations !")
						else
							RageUI.CloseAll()
							TriggerServerEvent('p0p0_ammu:rdv', nomprenom, num, motif)
							ESX.ShowNotification("Votre demande à bien était reçu par l'~r~Ammunation~s~ !")
							nomprenom = nil
							motif = nil
							num = nil
						end
					end
                end)
			end, function()end)
			Citizen.Wait(0)
		end
	end)
end

--secretariat marker--
Citizen.CreateThread(function()
    while true do
		local interval = 1
        Citizen.Wait(interval)

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Config.secretariat)
            if dist <= 15.0 then
				interval = 200
            end
			interval = 1
            if dist <= 1.0 then
                	AddTextEntry("secretariat", _U('secretariat'))
					DisplayHelpTextThisFrame("secretariat", false)
                if IsControlJustPressed(1,51) then
                    openrdvMenu()
                end
            end
    end
end)

--display blip--
Citizen.CreateThread(function()

    local blip = AddBlipForCoord(Config.Blip.Pos.x, Config.Blip.Pos.y, Config.Blip.Pos.z)
  
    SetBlipSprite (blip, Config.Blip.Sprite)
    SetBlipDisplay(blip, Config.Blip.Display)
    SetBlipScale  (blip, Config.Blip.Scale)
    SetBlipColour (blip, Config.Blip.Colour)
    SetBlipAsShortRange(blip, true)
  
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('ammu'))
    EndTextCommandSetBlipName(blip)
  
end)