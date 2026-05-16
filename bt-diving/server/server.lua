-- ox_inventory item-use export for the oxygen tank.
-- The items.lua entry for 'oxygentank' points server.export = 'bt-diving.oxygentank'
-- which calls this function when a player uses the item.
exports('oxygentank', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        -- inventory.id is the player server id
        TriggerClientEvent('diving:oxygenmask', inventory.id)
    end
end)

-- Weighted random item selection based on probability table in config
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

-- Server-side sanity check: player must be within a configured diving zone
local function isPlayerInDivingZone(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end

    local coords = GetEntityCoords(ped)

    for _, zone in ipairs(Config.DivingZones) do
        local dist = #(vector3(coords.x, coords.y, coords.z) - vector3(zone.coords.x, zone.coords.y, zone.coords.z))
        if dist <= zone.zoneRadius then
            return true
        end
    end
    return false
end

-- Per-player rate limiting: prevent event spam
local lastCollect = {}

RegisterNetEvent('diving:giveItem')
AddEventHandler('diving:giveItem', function()
    local source = source
    local now = GetGameTimer()

    if lastCollect[source] and (now - lastCollect[source]) < 3000 then
        return
    end
    lastCollect[source] = now

    if not isPlayerInDivingZone(source) then
        return
    end

    local item = pickRandomItem()
    local amount = math.random(item.min, item.max)

    exports.ox_inventory:AddItem(source, item.name, amount)

    if Config.ItemFoundNotify then
        TriggerClientEvent('bt-diving:notify', source,
            Config.Strings.noti_title2,
            Config.Strings.item_found .. amount .. 'x ' .. item.name,
            'success'
        )
    end
end)

RegisterNetEvent('diving:removeTank')
AddEventHandler('diving:removeTank', function()
    local source = source

    -- Verify the player still has the item before removing to prevent desync exploits
    local count = exports.ox_inventory:GetItemCount(source, Config.ScubaGearItem)
    if count and count > 0 then
        exports.ox_inventory:RemoveItem(source, Config.ScubaGearItem, 1)
    end
end)

AddEventHandler('playerDropped', function()
    lastCollect[source] = nil
end)
