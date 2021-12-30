local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local shownBossMenu = false

--[[AddEventHandler('onResourceStart', function(resource) --if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)]]

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('qb-bossmenu:client:inventory', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "Inv_" .. PlayerJob.label, {
        maxweight = 4000000,
        slots = 100,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "Inv_" .. PlayerJob.label)
end)

RegisterNetEvent('qb-bossmenu:client:wardrobe', function()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('qb-bossmenu:client:mainmenu', function()
	shownBossMenu = true
	local bossMenu = {
			{
				header = "Company menu - " ..string.upper(PlayerJob.label),
				isMenuHeader = true,
			},
			{
				header = "Manage Employees",
				txt = "Manage your employees, you can fire them or change their rank",
				params = {
					event = "qb-bossmenu:client:manageemployees",
				}
			},
			{
				header = "Hire Employees",
				txt = "You can hire nearby players in your club",
				params = {
					event = "qb-bossmenu:client:hiredEmployees",
				}
			},
			{
				header = "Inventory",
				txt = "Open the company's inventory",
				params = {
					event = "qb-bossmenu:client:inventory",
				}
			},
			{
				header = "Wardrobe",
				txt = "Open your wardrobe",
				params = {
					event = "qb-bossmenu:client:wardrobe",
				}
			},
			{
				header = "Company balance",
				txt = "Manage the company's balance, you can withdraw or deposit money",
				params = {
					event = "qb-bossmenu:client:firmcompany",
				}
			},
			{
				header = "Close",
				params = {
					event = "qb-menu:closeMenu",
				}
			},
		}
	exports['qb-menu']:openMenu(bossMenu)
end)

RegisterNetEvent('qb-bossmenu:client:manageemployees', function()
	local dipendentiMenu = {
		{
			header = "Manage employees - " ..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-bossmenu:server:GetEmployees', function(cb)
        for k,v in pairs(cb) do			
			dipendentiMenu[#dipendentiMenu+1] = {
				header = v.name,
				txt = v.grade.name,
				params = {
					event = "qb-bossmenu:client:manageemployee",
					args = {
						giocatore = v,
						lavoro = PlayerJob
					}
				}
			}
        end
		dipendentiMenu[#dipendentiMenu+1] = {
			header = "< Back",
			params = {
				event = "qb-bossmenu:client:mainmenu",
			}
		}
	exports['qb-menu']:openMenu(dipendentiMenu)
    end, PlayerJob.name)
end)

RegisterNetEvent('qb-bossmenu:client:manageemployee', function(data)
	local dipendenteMenu = {
		{
			header = "Manage" ..data.giocatore.name.. " - " ..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
	}
	for k, v in pairs(QBCore.Shared.Jobs[data.lavoro.name].grades) do
		dipendenteMenu[#dipendenteMenu+1] = {
			header = v.name,
			txt = "Degree: " ..k,
			params = {
				isServer = true,
				event = "qb-bossmenu:server:updateGrade",
				args = {
					cid = data.giocatore.empSource,
					grado = tonumber(k),
					nomegrado = v.name
				}
			}
		}
	end
	dipendenteMenu[#dipendenteMenu+1] = {
		header = "Fire",
		params = {
			isServer = true,
			event = "qb-bossmenu:server:firedPlayer",
			args = data.giocatore.empSource
		}
	}
	dipendenteMenu[#dipendenteMenu+1] = {
		header = "< Back",
		params = {
			event = "qb-bossmenu:client:manageemployees",
		}
	}
	exports['qb-menu']:openMenu(dipendenteMenu)
end)

RegisterNetEvent('qb-bossmenu:client:hiredEmployees', function()
	local hiredEmployeesMenu = {
		{
			header = "Hire employeei - " ..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-bossmenu:getplayers', function(players)
		for k,v in pairs(players) do
			if v and v ~= PlayerId() then
				hiredEmployeesMenu[#hiredEmployeesMenu+1] = {
					header = v.name,
					txt = "CID: " ..v.citizenid.. " - ID: " ..v.sourceplayer,
					params = {
						isServer = true,
						event = "qb-bossmenu:server:recruitPlayer",
						args = v.sourceplayer
					}
				}
			end
		end
		hiredEmployeesMenu[#hiredEmployeesMenu+1] = {
			header = "< Back",
			params = {
				event = "qb-bossmenu:client:mainmenu",
			}
		}
		exports['qb-menu']:openMenu(hiredEmployeesMenu)
	end)
end)

RegisterNetEvent('qb-bossmenu:client:firmcompany', function()
	QBCore.Functions.TriggerCallback('qb-bossmenu:server:GetAccount', function(cb)	
	local menuSaldosocieta = {
		{
			header = "Balance: £" .. comma_value(cb) .. " - "..string.upper(PlayerJob.label),
			isMenuHeader = true,
		},
		{
			header = "Deposita",
			txt = "Deposit money in your company's safe",
			params = {
				event = "qb-bossmenu:client:depositmoney",
				args = comma_value(cb)
			}
		},
		{
			header = "Withdraw",
			txt = "Withdraw money from your company vault",
			params = {
				event = "qb-bossmenu:client:withdrawmoney",
				args = comma_value(cb)
			}
		},
		{
			header = "< Back",
			params = {
				event = "qb-bossmenu:client:mainmenu",
			}
		},
	}
		exports['qb-menu']:openMenu(menuSaldosocieta)
	end, PlayerJob.name)
end)

RegisterNetEvent('qb-bossmenu:client:depositmoney', function(saldoattuale)
	local depositmoney = exports['qb-input']:ShowInput({
		header = "Deposit Money With Current Balance: £" ..saldoattuale,
		submitText = "Conferma",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = '£'
			}
		}
	})
	if depositmoney then
		if not depositmoney.amount then return end
		TriggerServerEvent("qb-bossmenu:server:depositMoney", tonumber(depositmoney.amount))
	end
end)

RegisterNetEvent('qb-bossmenu:client:withdrawmoney', function(saldoattuale)
	local withdrawmoney = exports['qb-input']:ShowInput({
		header = "Withdraw Money With Current Balance: £" ..saldoattuale,
		submitText = "Conferma",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = '"£"'
			}
		}
	})
	if withdrawmoney then
		if not withdrawmoney.amount then return end
		TriggerServerEvent("qb-bossmenu:server:withdrawMoney", tonumber(withdrawmoney.amount))
	end
end)

-- MAIN THREAD
CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local inRangeBoss = false
		local nearBossmenu = false
		for k, v in pairs(Config.Jobs) do
			if k == PlayerJob.name and PlayerJob.isboss then
				if #(pos - v) < 5.0 then
					inRangeBoss = true
						if #(pos - v) <= 1.5 then
							if not shownBossMenu then DrawText3D(v, "~b~E~w~ - Menu") end
							nearBossmenu = true
							if IsControlJustReleased(0, 38) then
								TriggerEvent("qb-bossmenu:client:mainmenu")
							end
						end

					if not nearBossmenu and shownBossMenu then
						CloseMenuFull()
						shownBossMenu = false
					end
				end
			end
		end
			if not inRangeBoss then
				Wait(1500)
				if shownBossMenu then
					CloseMenuFull()
					shownBossMenu = false
				end
			end
	Wait(5)
	end
end)

-- UTIL
function CloseMenuFull()
    exports['qb-menu']:closeMenu()
	shownBossMenu = false
end

function DrawText3D(v, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(v, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 0)
    ClearDrawOrigin()
end

function comma_value(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end
