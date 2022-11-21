ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Citizen.CreateThread(function()
	TriggerEvent('esx_society:registerSociety', 'ammu', 'Ammunation', 'society_ammu', 'society_ammu', 'society_ammu', {type = 'private'})
end)

RegisterServerEvent('popo_ammu_job:getStockItems')
AddEventHandler('popo_ammu_job:getStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
    local _source = source

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ammu', function(inventory)
		local item = inventory.getItem(itemName)

		if item.count >= count then
			inventory.removeItem(itemName, count)
			xPlayer.addInventoryItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', _source, 'Quantité invalide')
		end
		TriggerClientEvent('esx:showNotification', _source, 'tu as pris '..count..' '.. item.label..' au coffre')
	end)
end)

ESX.RegisterServerCallback('popo_ammu_job:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ammu', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('popo_ammu_job:putStockItems')
AddEventHandler('popo_ammu_job:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
    local _source = source

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_ammu', function(inventory)
		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', _source, 'Quantité invalide')
		end
        TriggerClientEvent('esx:showNotification', _source, 'tu as ajouté '..count..' '.. item.label..' au coffre')
	end)
end)

ESX.RegisterServerCallback('popo_ammu_job:getPlayerInventory', function(source, cb)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})
end)

RegisterServerEvent('p0p0_ammu:open')
AddEventHandler('p0p0_ammu:open', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], "L'Ammunation est désormais ~g~Ouvert~s~ !")
	end
end)

RegisterServerEvent('p0p0_ammu:close')
AddEventHandler('p0p0_ammu:close', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], "L'Ammunation est désormais ~r~Fermer~s~ !")
	end
end)

RegisterServerEvent('p0p0_ammu:recrutement')
AddEventHandler('p0p0_ammu:recrutement', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showNotification', xPlayers[i], "L'Ammunation recrutent, rendez vous à l'~r~Ammunation~s~")
	end
end)

RegisterServerEvent('p0p0_ammu:appel')
AddEventHandler('p0p0_ammu:appel', function()
    
	local xPlayers = ESX.GetPlayers()
	for i = 1, #xPlayers, 1 do
		local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
		if thePlayer.job.name == 'ammu' then
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Ammunations', '~r~Accueil', 'Un client attends à l\'accueil !', 'CHAR_ammu', 8)
        end
    end
end)

local function sendToDiscordWithSpecialURL(Color, Title, Description)
	local Content = {
	        {
	            ["color"] = Color,
	            ["title"] = Title,
	            ["description"] = Description,
		        ["footer"] = {
	            ["text"] = "p0p0 Ammunation",
	            ["icon_url"] = nil,
	            },
	        }
	    }
	PerformHttpRequest(ConfigWebhookRendezVous, function(err, text, headers) end, 'POST', json.encode({username = Name, embeds = Content}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("p0p0_ammu:rdv")
AddEventHandler("p0p0_ammu:rdv", function(nomprenom, numero, rdvmotif)
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local ident = xPlayer.getIdentifier()
	local date = os.date('*t')

	if date.day < 10 then date.day = '' .. tostring(date.day) end
	if date.month < 10 then date.month = '' .. tostring(date.month) end
	if date.hour < 10 then date.hour = '' .. tostring(date.hour) end
	if date.min < 10 then date.min = '' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '' .. tostring(date.sec) end

	if ident == 'steam:11' then --Special character in username just crash the server
	else 
		sendToDiscordWithSpecialURL(15080747, "Demande de Rendez-Vous Ammunation\n\n```Prénom et Nom : "..nomprenom.."\n\nNuméro de Téléphone: "..numero.."\n\nMotif du Rendez-vous : " ..rdvmotif.. "\n\n```Date : " .. date.day .. "." .. date.month .. "." .. date.year .. " | " .. date.hour .. " h " .. date.min .. " min " .. date.sec)
	end
end)

--Webhook pour l'accueil
ConfigWebhookRendezVous = "LIEN_WEBHOOK"