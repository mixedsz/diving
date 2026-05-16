local ESX, QBCore

if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "QB" then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Register the oxygen tank as a usable item so players can equip it from inventory
if Config.Framework == "ESX" then
    ESX.RegisterUsableItem(Config.ScubaGearItem, function(source)
        TriggerClientEvent('diving:oxygenmask', source)
    end)
elseif Config.Framework == "QB" then
    QBCore.Functions.CreateUseableItem(Config.ScubaGearItem, function(source)
        TriggerClientEvent('diving:oxygenmask', source)
    end)
end

local function getPlayer(source)
    if Config.Framework == "ESX" then
        return ESX.GetPlayerFromId(source)
    elseif Config.Framework == "QB" then
        return QBCore.Functions.GetPlayer(source)
    end
end

-- Weighted random item selection based on probability table
local function pickRandomItem()
    local roll = math.random()
    local cumulative = 0.0
    for _, item in ipairs(Config.Items) do
        cumulative = cumulative + item.probability
        if roll <= cumulative then
            return item
        end
    end
    return Config.Items[#Config.Items]
end

-- Basic server-side sanity check: player must be in/near a configured diving zone
local function isPlayerInDivingZone(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end

    local coords = GetEntityCoords(ped)

    for _, zone in ipairs(Config.DivingZones) do
        local zoneCoords = zone.coords
        local dist = #(vector3(coords.x, coords.y, coords.z) - vector3(zoneCoords.x, zoneCoords.y, zoneCoords.z))
        if dist <= zone.zoneRadius then
            return true
        end
    end
    return false
end

-- Per-player rate limiting: prevent spamming giveItem
local lastCollect = {}

RegisterNetEvent('diving:giveItem')
AddEventHandler('diving:giveItem', function()
    local source = source
    local now = GetGameTimer()

    -- Rate limit: at most once every 3 seconds per player
    if lastCollect[source] and (now - lastCollect[source]) < 3000 then
        return
    end
    lastCollect[source] = now

    if not isPlayerInDivingZone(source) then
        return
    end

    local item = pickRandomItem()
    local amount = math.random(item.min, item.max)

    if Config.Framework == "ESX" then
        local xPlayer = getPlayer(source)
        if not xPlayer then return end

        xPlayer:addItem(item.name, amount)

        if Config.ItemFoundNotify then
            TriggerClientEvent('bt-diving:notify', source,
                Config.Strings.noti_title2,
                Config.Strings.item_found .. amount .. 'x ' .. item.name,
                'success'
            )
        end

    elseif Config.Framework == "QB" then
        local Player = getPlayer(source)
        if not Player then return end

        Player.Functions.AddItem(item.name, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item.name], "add", amount)

        if Config.ItemFoundNotify then
            TriggerClientEvent('bt-diving:notify', source,
                Config.Strings.noti_title2,
                Config.Strings.item_found .. amount .. 'x ' .. item.name,
                'success'
            )
        end
    end
end)

RegisterNetEvent('diving:removeTank')
AddEventHandler('diving:removeTank', function()
    local source = source

    if Config.Framework == "ESX" then
        local xPlayer = getPlayer(source)
        if not xPlayer then return end

        -- Only remove if the player actually has the item to prevent desync exploits
        local item = xPlayer:getInventoryItem(Config.ScubaGearItem)
        if item and item.count > 0 then
            xPlayer:removeItem(Config.ScubaGearItem, 1)
        end

    elseif Config.Framework == "QB" then
        local Player = getPlayer(source)
        if not Player then return end

        local item = Player.Functions.GetItemByName(Config.ScubaGearItem)
        if item and item.amount > 0 then
            Player.Functions.RemoveItem(Config.ScubaGearItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.ScubaGearItem], "remove", 1)
        end
    end
end)

-- Clean up rate limit table when player drops to avoid memory leak
AddEventHandler('playerDropped', function()
    local source = source
    lastCollect[source] = nil
end)
