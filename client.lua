local RSGCore = exports['rsg-core']:GetCoreObject()
local isEventActive = false
local isLocalOnly = false
local playerPed = nil
local slowMotionFactor = Config.slomo  

local function Notify(text, notifyType)
    notifyType = notifyType or 'inform' 
    if GetResourceState('ox_lib') == 'started' then
        lib.notify({
            title = 'Broken Clock',
            description = text,
            type = notifyType
        })
    else
       
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandThefeedPostTicker(notifyType == 'success' and 1 or 2, false)
    end
end


RegisterNetEvent('rsg-brokenclock:clientNotify', function(text)
    Notify(text, 'error')
end)

RegisterNetEvent('rsg-brokenclock:clientStartEvent', function(localOnly)
	
    if isEventActive then
       
        return
    end
    isEventActive = true
    isLocalOnly = localOnly or false

   
    Citizen.CreateThread(function()
        playerPed = PlayerPedId()
       

       
        TriggerEvent('rsg-brokenclock:premonition')
        Wait((Config.PremonitionDuration or 3) * 1000)

       
        TriggerEvent('rsg-brokenclock:freeze')
        Wait((Config.FreezeDuration or 5) * 1000)

        
        local chance = tonumber(Config.ExtraAnomalyChance) or 0
        if math.random(1, 100) <= chance then
            TriggerEvent('rsg-brokenclock:extraAnomaly')
        end

       
        TriggerEvent('rsg-brokenclock:endEvent')
        isEventActive = false
       
    end)
end)

AddEventHandler('rsg-brokenclock:premonition', function()
   
    
    TriggerServerEvent('InteractSound_SV:PlayOnAll', 'clock', 0.7)
    SetTimecycleModifier("hud_def_blur")
    SetTimecycleModifierStrength(0.3)
    Notify("The clock... it's stuttering.", "primary")
end)

AddEventHandler('rsg-brokenclock:freeze', function()
   
    ClearTimecycleModifier()  
   
    SetTimecycleModifierStrength(1.0)

    playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then
       
        return
    end

    
    TriggerServerEvent('InteractSound_SV:PlayOnAll', 'clock', 0.7)

   
    SetTimeScale(slowMotionFactor)

   
    local playerCoords = GetEntityCoords(playerPed)
    local pool = (GetGamePool and GetGamePool('CPed')) or {}

    for _, ped in ipairs(pool) do
        if DoesEntityExist(ped) and ped ~= playerPed then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(playerCoords - pedCoords)
            local freezeDist = isLocalOnly and 100.0 or 5000.0  
            if dist < freezeDist then
                
                ClearPedTasksImmediately(ped)
                
                SetPedMoveRateOverride(ped, slowMotionFactor)
                SetEntityAnimSpeed(ped, slowMotionFactor)
                SetEntityInvincible(ped, true)
                SetPedCanPlayAmbientAnims(ped, false)
                SetPedCanPlayGestureAnims(ped, false)
                SetPedCanRagdoll(ped, false)
                SetBlockingOfNonTemporaryEvents(ped, true)
            end
        end
    end

    Notify("Time... slows to a crawl.", "error")
end)

RegisterNetEvent('InteractSound_CL:StopSound', function(soundName)
    SendNUIMessage({
        transactionType = 'stopSound',
        transactionFile = soundName
    })
end)


AddEventHandler('rsg-brokenclock:extraAnomaly', function()
   
    local rand = math.random(1, 3)
    if rand == 1 then
       
        local model = GetHashKey("re_frozentodeath_males_01")
        if IsModelInCdimage(model) and IsModelValid(model) then
            RequestModel(model)
            local timeout = 2000
            while not HasModelLoaded(model) and timeout > 0 do
                Wait(10); timeout = timeout - 10
            end
            if HasModelLoaded(model) then
                local spawnCoords = GetEntityCoords(PlayerPedId()) + vector3(0, 2, 0)
                local ghost = CreatePed(4, model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, false, true)
                if DoesEntityExist(ghost) then
                    SetEntityAlpha(ghost, 100, false)
                    SetEntityCollision(ghost, false, false)
                    TaskWanderStandard(ghost, 10.0, 10)
                    Wait(5000)
                    DeleteEntity(ghost)
                    Notify("A ghost whispers from the shadows...", "primary")
                end
                SetModelAsNoLongerNeeded(model)
            else
                Notify("The shadows stir, but nothing appears...", "primary")  -- Fallback notification
            end
        end

    elseif rand == 2 then
        
        local itemHash = GetHashKey("p_watchgold03x")
        if IsModelInCdimage(itemHash) and IsModelValid(itemHash) then
            RequestModel(itemHash)
            local timeout = 2000
            while not HasModelLoaded(itemHash) and timeout > 0 do
                Wait(10); timeout = timeout - 10
            end
            if HasModelLoaded(itemHash) then
                local obj = CreateObject(itemHash, GetEntityCoords(PlayerPedId()) + vector3(0, 1, 0), true, true, false)
                PlaceObjectOnGroundProperly(obj)
                Notify("A cursed watch materializes at your feet.", "success")
                SetModelAsNoLongerNeeded(itemHash)
            else
                Notify("A chill runs down your spine...", "primary")  -- Fallback
            end
        end

    else
        
        local hour, minute, second = GetClockHours(), GetClockMinutes(), GetClockSeconds and GetClockSeconds() or 0
        hour = tonumber(hour) or 0
        minute = tonumber(minute) or 0
        local newHour = (hour + 1) % 24
        
        if type(NetworkOverrideClockTime) == 'function' then
            NetworkOverrideClockTime(newHour, minute, 0)
            Wait(2000)
            NetworkClearClockTimeOverride()
        end
        Notify("Time lurches forward!", "error")
    end
end)

AddEventHandler('rsg-brokenclock:endEvent', function()
   
    
    
    TriggerServerEvent('InteractSound_SV:StopSound', 'clock')

   
    SetTimeScale(1.0)

    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)
	Wait(500)
	StopGameplayCamShaking(true)
    DoScreenFadeOut(1000)
    Wait(1200)

    
    for i = 10, 0, -1 do
        SetTimecycleModifierStrength(i / 10.0)
        Wait(150)
    end
    ClearTimecycleModifier()

    playerPed = PlayerPedId()
    if playerPed and playerPed ~= 0 then
        SetEntityVisible(playerPed, true, false)
        
    end

    
    local playerCoords = GetEntityCoords(playerPed)
    local pool = (GetGamePool and GetGamePool('CPed')) or {}
    for _, ped in ipairs(pool) do
        if DoesEntityExist(ped) and ped ~= playerPed then
            local pedCoords = GetEntityCoords(ped)
            local dist = #(playerCoords - pedCoords)
            local freezeDist = isLocalOnly and 100.0 or 5000.0  
            if dist < freezeDist then
                
                ClearPedTasks(ped)  
                TaskWanderStandard(ped, 10.0, 10) 
                
                SetPedMoveRateOverride(ped, 1.0) 
                SetEntityAnimSpeed(ped, 1.0)
                SetEntityInvincible(ped, false)
                SetBlockingOfNonTemporaryEvents(ped, false)
                SetPedCanPlayAmbientAnims(ped, true)
                SetPedCanPlayGestureAnims(ped, true)
                SetPedCanRagdoll(ped, true)
            end
        end
    end

    NetworkClearClockTimeOverride()

   
    DoScreenFadeIn(1500)
    Wait(800)
    Notify("Reality snaps back...", "success")
end)


RegisterCommand('resetclock', function() isEventActive = false; print('[CLIENT] Reset event state') end)

RegisterCommand('cursedwatch', function()
    TriggerServerEvent('rsg-brokenclock:serverManualTrigger')
end, false)

--[[
Citizen.CreateThread(function()
    while true do
        Wait(60000) 
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        TriggerServerEvent('rsg-brokenclock:updateServerTime', hour, minute)
    end
end)
--]]

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        ClearTimecycleModifier()
        SetTimeScale(1.0)
        local ped = PlayerPedId()
        if ped and ped ~= 0 then
            FreezeEntityPosition(ped, false)
            EnableAllControlActions(0)
        end
        NetworkClearClockTimeOverride()
    end
end)