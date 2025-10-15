
local RSGCore = exports['rsg-core']:GetCoreObject()

Citizen.CreateThread(function()
    Wait(3000)
    if exports['weathersync'] and exports['weathersync'].getTime then
        
        local ts = exports['weathersync']:getTime()
        
    else
        
    end
end)


if not Config then
    return
end


if Config.AllowManualItemTrigger and Config.ManualTriggerItemName then
    RSGCore.Functions.CreateUseableItem(Config.ManualTriggerItemName, function(source, item)
        local Player = RSGCore.Functions.GetPlayer(source)
        if Player then
            TriggerClientEvent('rsg-brokenclock:clientStartEvent', source, true)
            
            TriggerClientEvent('inventory:client:ItemBox', source, RSGCore.Shared.Items[Config.ManualTriggerItemName], "remove")
            Player.Functions.RemoveItem(Config.ManualTriggerItemName, 0)
        end
    end)
end


local function getServerTime()
    local ts = exports.weathersync:getTime()
    if not ts then
        return 0, 0
    end
    local hour = tonumber(ts.hour) or 0
    local minute = tonumber(ts.minute) or 0
    return hour, minute
end


local function playerInActiveArea(coords)
    if not Config.ActiveAreas or #Config.ActiveAreas == 0 then return false end
    for _, area in ipairs(Config.ActiveAreas) do
        local dx, dy, dz = coords.x - area.x, coords.y - area.y, coords.z - (area.z or 0)
        if (dx * dx + dy * dy + dz * dz) <= (area.radius * area.radius) then
            return true
        end
    end
    return false
end


local function triggerBrokenClockForPlayers(localOnlyFlag)
    if Config.GlobalEvent then
        TriggerClientEvent('rsg-brokenclock:clientStartEvent', -1, localOnlyFlag or false)
        return
    end

    for _, id in ipairs(GetPlayers()) do
        local pid = tonumber(id)
        local ped = GetPlayerPed(pid)
        if ped and ped ~= 0 and DoesEntityExist(ped) then
            local pos = GetEntityCoords(ped)
            if playerInActiveArea({ x = pos.x, y = pos.y, z = pos.z }) then
                TriggerClientEvent('rsg-brokenclock:clientStartEvent', pid, localOnlyFlag or false)
            end
        end
    end
end


Citizen.CreateThread(function()
   

    while true do
        local interval = tonumber(Config.TimeCheckInterval) or 30
        Wait(interval * 1000)

        
        if not exports['weathersync'] or not exports['weathersync'].getTime then
           
            goto continue
        end

        
        local ts = exports['weathersync']:getTime()
        if not ts or not ts.hour or not ts.minute then
            
            goto continue
        end

        local hour = tonumber(ts.hour) or 0
        local minute = tonumber(ts.minute) or 0

        

       
        if hour == Config.TriggerHour and math.abs(minute - Config.TriggerMinute) <= 1 then
           
            TriggerEvent('rsg-brokenclock:attemptTrigger', hour, minute)
            Wait(61 * 1000) 
        end

        ::continue::
    end
end)



local lastTriggered = nil

AddEventHandler('rsg-brokenclock:attemptTrigger', function(hour, minute)
    local stamp = string.format('%02d:%02d', tonumber(hour) or 0, tonumber(minute) or 0)
    if lastTriggered == stamp then
        if Config.Debug then
            
        end
        return
    end
    lastTriggered = stamp

    triggerBrokenClockForPlayers()

    if Config.AdvanceMinutesAfterEvent and tonumber(Config.AdvanceMinutesAfterEvent) > 0 then
        TriggerEvent('rsg-brokenclock:advanceTime', tonumber(Config.AdvanceMinutesAfterEvent))
    end

    if Config.Debug then
       
    end
end)


RegisterNetEvent('rsg-brokenclock:advanceTime', function(minutes)
    minutes = tonumber(minutes) or 0
    if minutes <= 0 then return end

    local ts = exports.weathersync:getTime()
    if not ts then return end

    local totalMinutes = (ts.hour * 60) + ts.minute + minutes
    local newHour = math.floor(totalMinutes / 60) % 24
    local newMinute = totalMinutes % 60

   
    exports.weathersync:setTime(ts.day, newHour, newMinute, 0, true, false)

    
end)


RegisterNetEvent('InteractSound_SV:StopSound', function(soundName)
    TriggerClientEvent('InteractSound_CL:StopSound', -1, soundName)
end)


RegisterNetEvent('rsg-brokenclock:serverManualTrigger', function()
    local src = source

    if Config.AllowManualItemTrigger == false and src ~= 0 then
        TriggerClientEvent('rsg-brokenclock:clientNotify', src, 'Manual trigger disabled!')
        return
    end

    if src == 0 then
        triggerBrokenClockForPlayers()
        return
    end

    TriggerClientEvent('rsg-brokenclock:clientStartEvent', src, true)
end)