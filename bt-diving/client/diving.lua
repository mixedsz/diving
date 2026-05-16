if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "QB" then
    QBCore = exports['qb-core']:GetCoreObject()
end

local usingOxygenMask = false
local hasOxygenTank = false
local airSupply = 100
local oxygenUsageRate = 1 
local isDiving = false

Citizen.CreateThread(function()
    for k, v in pairs(Config.DivingZones) do
        local blip = AddBlipForRadius(v.coords.x, v.coords.y, v.coords.z, v.zoneRadius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, v.radiusColor)
        SetBlipAlpha (blip, 128)

        local blip2 = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip2, v.sprite) 
        SetBlipDisplay(blip2, 4)
        SetBlipScale(blip2, v.scale)
        SetBlipColour(blip2, v.color)
        SetBlipAsShortRange(blip2, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(blip2)
    end
end)

local salvageAreas = {}

for _, v in ipairs(Config.DivingZones) do
    table.insert(salvageAreas, CircleZone:Create(v.coords, v.zoneRadius, {
        name="Salvage Zone",
        useZ=false
    }))
end

CreateThread(function()
    while true do
        local sleep = 2500
        local ped = cache.ped

        for _, zone in ipairs(salvageAreas) do
            if zone:isPointInside(GetEntityCoords(ped)) then
                if usingOxygenMask then
                    sleep = 750
                    if IsPedSwimmingUnderWater(ped) then
                        isDiving = true
                    else
                        isDiving = false
                    end
                end
                break
            end
        end

        Wait(sleep)
    end
end)

local capsules = {}

function SpawnCapsule(zoneCoords, radius)
    local xOffset = math.random(-radius/2, radius/2)
    local yOffset = math.random(-radius/2, radius/2)
    local zOffset = math.random(8, 20)

    local capsule = CreateObject(GetHashKey('prop_time_capsule_01'), zoneCoords.x + xOffset, zoneCoords.y + yOffset, zoneCoords.z - zOffset, true, true, true)

    table.insert(capsules, capsule)
end

CreateThread(function()
    while true do
        if isDiving then
            local isInAnyZone = false
            local currentZoneCoords = nil
            local playerPed = cache.ped
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, zone in ipairs(salvageAreas) do
                if zone:isPointInside(playerCoords) then
                    isInAnyZone = true
                    currentZoneCoords = zone.center
                    if isInAnyZone then
                        if #capsules < Config.MaximumCapsules then
                            SpawnCapsule(currentZoneCoords, zone.radius)
                        end
                    end
                end
            end
        end

        Wait(12500)
    end
end)

function CheckPlayerNearbyCapsules()
    local player = cache.playerId
    local ped = GetPlayerPed(player)
    local playerPos = GetEntityCoords(ped)

    for i=#capsules, 1, -1 do
        local capsulePos = GetEntityCoords(capsules[i])
        local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, capsulePos.x, capsulePos.y, capsulePos.z, true)

        if distance < 2.0 then 
            DeleteObject(capsules[i])
            table.remove(capsules, i)
            TriggerServerEvent("diving:giveItem")
            if Config.PlaySound then
                PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
            end
        end
    end
end

CreateThread(function()
    local sleep = 5000
    while true do
        if isDiving then
            sleep = 0
            CheckPlayerNearbyCapsules()

            local playerPos = GetEntityCoords(cache.ped)
            for i=1, #capsules do
                local capsulePos = GetEntityCoords(capsules[i])
                local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, capsulePos.x, capsulePos.y, capsulePos.z, true)
                DrawText3D(capsulePos.x, capsulePos.y, capsulePos.z, string.format("Distance: %.2f", distance))
            end
        else
            sleep = 5000
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('diving:oxygenmask')
AddEventHandler('diving:oxygenmask', function()
    if not usingOxygenMask then
        if Config.ProgressBar == "OX" then
            if lib.progressBar({
                duration = Config.EquipTime * 1000,
                label = Config.Strings.apply_oxygentank,
                useWhileDead = false,
                allowSwimming = true,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    dict = 'clothingtie',
                    clip = 'try_tie_negative_a'
                },
            }) then 
                TriggerEvent("diving:oxygenmaskApply")
            else
                TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, Config.Strings.cancel_oxygentank, 'error')
            end
        elseif Config.ProgressBar == "ESX" then
            exports["esx_progressbar"]:Progressbar(Config.Strings.apply_oxygentank, Config.EquipTime * 1000,{
                FreezePlayer = false, 
                animation ={
                    type = "anim",
                    dict = "clothingtie", 
                    lib = "try_tie_negative_a"
                },
                onFinish = function()
                    TriggerEvent("diving:oxygenmaskApply")
            end})
        elseif Config.ProgressBar == "QB" then
            QBCore.Functions.Progressbar('ApplyOxygenTank', Config.Strings.apply_oxygentank, Config.EquipTime * 1000, false, true, {
                disableMovement = false,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
                },   
               {
                    animDict = "clothingtie",
                    anim = "try_tie_negative_a",
                }, {}, {}, function()
                    TriggerEvent("diving:oxygenmaskApply")
                end, function()
                    TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, Config.Strings.cancel_oxygentank, 'error')
            end)
        end
    else
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, Config.Strings.already_applied, 'error')
    end
end)

RegisterNetEvent('diving:oxygenmaskApply')
AddEventHandler('diving:oxygenmaskApply', function()
    local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local x, y, z = table.unpack(coords + forward * 1.0)

    if not usingOxygenMask then
        local maskModel = GetHashKey('p_s_scuba_mask_s')
        local tankModel = GetHashKey('p_s_scuba_tank_s')

        RequestModel(maskModel)
        while not HasModelLoaded(maskModel) do
            Wait(1)
        end

        RequestModel(tankModel)
        while not HasModelLoaded(tankModel) do
            Wait(1)
        end

        local mask = CreateObject(maskModel, x, y, z, true, true, true)
        local tank = CreateObject(tankModel, x, y, z, true, true, true)

        local maskBoneIndex = GetPedBoneIndex(playerPed, 12844)
        local tankBoneIndex = GetPedBoneIndex(playerPed, 24818)

        AttachEntityToEntity(mask, playerPed, maskBoneIndex, 0.0, 0.0, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
        AttachEntityToEntity(tank, playerPed, tankBoneIndex, -0.30, -0.22, 0.0, 0.0, 90.0, 180.0, true, true, false, true, 1, true)
        
        SetPedDiesInWater(playerPed, false)

        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, Config.Strings.applied_scubagear .. ' Oxygen level: 100%', 'success')
        
        if Config.RemoveTankOnUse then
            TriggerServerEvent('diving:removeTank')
        end

        usingOxygenMask = true

        Wait(Config.OxygenTankDuration / 4 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 75%', 'error')

        Wait(Config.OxygenTankDuration / 4 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 50%', 'error')

        Wait(Config.OxygenTankDuration / 4 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 25%', 'error')

        Wait(Config.OxygenTankDuration / 5 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 5%', 'error')

        Wait(Config.OxygenTankDuration / 100 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 4%', 'error')

        Wait(Config.OxygenTankDuration / 100 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 3%', 'error')

        Wait(Config.OxygenTankDuration / 100 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 2%', 'error')

        Wait(Config.OxygenTankDuration / 100 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 1%', 'error')

        Wait(Config.OxygenTankDuration / 100 * 60000)
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, 'Oxygen Level: 0%', 'error')

        if isDiving then
            isDiving = false
        end

        SetPedDiesInWater(playerPed, true)
        DeleteObject(mask)
        DeleteObject(tank)
        ClearPedSecondaryTask(playerPed)
        SetModelAsNoLongerNeeded(maskModel)
        SetModelAsNoLongerNeeded(tankModel)

        usingOxygenMask = false
    else
        TriggerEvent("bt-diving:notify", Config.Strings.noti_title1, Config.Strings.already_applied, 'error')
    end
end)


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale =  0.85
    local scale = scale
    if onScreen then
        SetTextScale(0.0, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

RegisterNetEvent("bt-diving:notify")
AddEventHandler("bt-diving:notify", function(title, text, nType)
    if Config.Notify == "OX" then
        lib.notify({
            title = title,
            description = text,
            position = 'center-right',
            type = nType
        })
    elseif Config.Notify == "ESX" then
        TriggerEvent('esx:showNotification', text, nType, 5000)
    elseif Config.Notify == "QB" then
        QBCore.Functions.Notify(text, 'success', 5000)
    end
end)