local QBCore = exports['qb-core']:GetCoreObject()
local PlayerGang = {}
local shownGangMenu = false

--[[AddEventHandler('onResourceStart', function(resource) --if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerGang = QBCore.Functions.GetPlayerData().gang
    end
end)]]

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerGang = QBCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

RegisterNetEvent('qb-gangmenu:client:inventory', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "Inv_" .. PlayerGang.label, {
        maxweight = 5000000,
        slots = 100,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "Inv_" .. PlayerGang.label)
end)

RegisterNetEvent('qb-gangmenu:client:wardrobe', function()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('qb-gangmenu:client:mainmenu', function()
	shownGangMenu = true
	local gangMenu = {
			{
				header = "Faction menu - " ..string.upper(PlayerGang.label),
				isMenuHeader = true,
			},
			{
				header = "Manage Affiliates",
				txt = "Manage your affiliates, you can change their rank here",
				params = {
					event = "qb-gangmenu:client:manageemployees",
				}
			},
			{
				header = "Hire Affiliates",
				txt = "You can affiliate players nearby",
				params = {
					event = "qb-gangmenu:client:hiredEmployees",
				}
			},
			{
				header = "Inventory",
				txt = "Open the Faction Inventory",
				params = {
					event = "qb-gangmenu:client:inventory",
				}
			},
			{
				header = "Wardrobe",
				txt = "Open your wardrobe",
				params = {
					event = "qb-gangmenu:client:wardrobe",
				}
			},
			{
				header = "Faction balance",
				txt = "Manage the balance of the faction, you can withdraw or deposit money",
				params = {
					event = "qb-gangmenu:client:firmcompany",
				}
			},
			{
				header = "Close",
				params = {
					event = "qb-menu:closeMenu",
				}
			},
		}
	exports['qb-menu']:openMenu(gangMenu)
end)

RegisterNetEvent('qb-gangmenu:client:manageemployees', function()
	local dipendentiMenuGang = {
		{
			header = "Gestisci Affiliati - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-gangmenu:server:GetEmployees', function(cb)
        for k,v in pairs(cb) do			
			dipendentiMenuGang[#dipendentiMenuGang+1] = {
				header = v.name,
				txt = v.grade.name,
				params = {
					event = "qb-gangmenu:client:manageemployee",
					args = {
						giocatore = v,
						lavoro = PlayerGang
					}
				}
			}
        end
		dipendentiMenuGang[#dipendentiMenuGang+1] = {
			header = "< Back",
			params = {
				event = "qb-gangmenu:client:mainmenu",
			}
		}
	exports['qb-menu']:openMenu(dipendentiMenuGang)
    end, PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:client:manageemployee', function(data)
	local dipendenteMenuGang = {
		{
			header = "Manage " ..data.giocatore.name.. " - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	for k, v in pairs(QBCore.Shared.Gangs[data.lavoro.name].grades) do
		dipendenteMenuGang[#dipendenteMenuGang+1] = {
			header = v.name,
			txt = "Degree: " ..k,
			params = {
				isServer = true,
				event = "qb-gangmenu:server:updateGrade",
				args = {
					cid = data.giocatore.empSource,
					grado = tonumber(k),
					nomegrado = v.name
				}
			}
		}
	end
	dipendenteMenuGang[#dipendenteMenuGang+1] = {
		header = "Throw out",
		params = {
			isServer = true,
			event = "qb-gangmenu:server:firedPlayer",
			args = data.giocatore.empSource
		}
	}
	dipendenteMenuGang[#dipendenteMenuGang+1] = {
		header = "< Back",
		params = {
			event = "qb-gangmenu:client:manageemployees",
		}
	}
	exports['qb-menu']:openMenu(dipendenteMenuGang)
end)

RegisterNetEvent('qb-gangmenu:client:hiredEmployees', function()
	local hiredEmployeesMenuGang = {
		{
			header = "Hire employees - " ..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
	}
	QBCore.Functions.TriggerCallback('qb-gangmenu:getplayers', function(players)
		for k,v in pairs(players) do
			if v and v ~= PlayerId() then
				hiredEmployeesMenuGang[#hiredEmployeesMenuGang+1] = {
					header = v.name,
					txt = "CID: " ..v.citizenid.. " - ID: " ..v.sourceplayer,
					params = {
						isServer = true,
						event = "qb-gangmenu:server:recruitPlayer",
						args = v.sourceplayer
					}
				}
			end
		end
		hiredEmployeesMenuGang[#hiredEmployeesMenuGang+1] = {
			header = "< Back",
			params = {
				event = "qb-gangmenu:client:mainmenu",
			}
		}
		exports['qb-menu']:openMenu(hiredEmployeesMenuGang)
	end)
end)

RegisterNetEvent('qb-gangmenu:client:firmcompany', function()
	QBCore.Functions.TriggerCallback('qb-gangmenu:server:GetAccount', function(cb)	
	local menuSaldosocieta = {
		{
			header = "Balance: £" .. comma_valueGang(cb) .. " - "..string.upper(PlayerGang.label),
			isMenuHeader = true,
		},
		{
			header = "Deposit",
			txt = "Deposit money in your faction's safe",
			params = {
				event = "qb-gangmenu:client:depositmoney",
				args = comma_valueGang(cb)
			}
		},
		{
			header = "Withdraw",
			txt = "Withdraw money from your faction's safe",
			params = {
				event = "qb-gangmenu:client:withdrawmoney",
				args = comma_valueGang(cb)
			}
		},
		{
			header = "< Back",
			params = {
				event = "qb-gangmenu:client:mainmenu",
			}
		},
	}
		exports['qb-menu']:openMenu(menuSaldosocieta)
	end, PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:client:depositmoney', function(saldoattuale)
	local depositmoney = exports['qb-input']:ShowInput({
		header = "Deposit Money With Current Balance: £" ..saldoattuale,
		submitText = "Confirmation",
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
		TriggerServerEvent("qb-gangmenu:server:depositMoney", tonumber(depositmoney.amount))
	end
end)

RegisterNetEvent('qb-gangmenu:client:withdrawmoney', function(saldoattuale)
	local withdrawmoney = exports['qb-input']:ShowInput({
		header = "Withdraw Money With Current Balance: £" ..saldoattuale,
		submitText = "Confirmation",
		inputs = {
			{
				type = 'number',
				isRequired = true,
				name = 'amount',
				text = '£'
			}
		}
	})
	if withdrawmoney then
		if not withdrawmoney.amount then return end
		TriggerServerEvent("qb-gangmenu:server:withdrawMoney", tonumber(withdrawmoney.amount))
	end
end)

-- MAIN THREAD
CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local inRangeGang = false
		local nearGangmenu = false
		for k, v in pairs(Config.Gangs) do
			if k == PlayerGang.name and PlayerGang.isboss then
				if #(pos - v) < 5.0 then
					inRangeGang = true
						if #(pos - v) <= 1.5 then
							if not shownGangMenu then DrawText3DGang(v, "~b~E~w~ - Open Menu") end
							nearGangmenu = true
							if IsControlJustReleased(0, 38) then
								TriggerEvent("qb-gangmenu:client:mainmenu")
							end
						end

					if not nearGangmenu and shownGangMenu then
						CloseMenuFull()
						shownGangMenu = false
					end
				end
			end
		end
			if not inRangeGang then
				Wait(1500)
				if shownGangMenu then
					CloseMenuFullGang()
					shownGangMenu = false
				end
			end
	Wait(5)
	end
end)

-- UTIL
function CloseMenuFullGang()
    exports['qb-menu']:closeMenu()
	shownGangMenu = false
end

function DrawText3DGang(v, text)
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

function comma_valueGang(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end
