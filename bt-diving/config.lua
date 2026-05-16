Config = {}

Config.Framework = "ESX" -- "ESX" for ESX | "QB" for QB Core
Config.Notify = "OX" -- "ESX" for ESX | "QB" for QB Core | "OX" for OX_Lib Notify
Config.ProgressBar = "OX" -- "ESX" for ESX | "QB" for QB Core | "OX" for OX_Lib Progress Bar

Config.Items = {  -- Probablity Must Add Up to 100
    {name="trash", probability = 0.22, min = 1, max = 2},
    {name="fishingrod", probability = 0.03, min = 1, max = 1},
    {name="plastic", probability = 0.09, min = 1, max = 2}, 
    {name="rubber", probability = 0.12, min = 1, max = 2},
    {name="steel", probability = 0.09, min = 1, max = 2}, 
    {name="scrapmetal", probability = 0.08, min = 1, max = 3},  	
    {name="iron", probability = 0.03, min = 1, max = 2},
    {name="nylonrope", probability = 0.05, min = 1, max = 1},
    {name="pliers", probability = 0.05, min = 1, max = 1},
    {name="electronics", probability = 0.05, min = 1, max = 1},
    {name="blowtorch", probability = 0.04, min = 1, max = 1},
    {name="x_device", probability = 0.04, min = 1, max = 1},
    {name="glass_cutter", probability = 0.01, min = 1, max = 1},
}

Config.ScubaGearItem = "oxygentank" -- Name of Scuba Gear Item
Config.RemoveTankOnUse = true -- Should the tank be removed on use

Config.MaximumCapsules = 8 -- Maximum Amount of Capsules Concurrently 
Config.OxygenTankDuration = 10 -- Amount of time 1 Oxygen Tank Lasts (In Minutes)
Config.EquipTime = 7.5 -- Amount of time it takes to equip Oxygen Tank (In Seconds)
Config.PlaySound = true -- Should a sound be played when a capsule is collected
Config.ItemFoundNotify = true -- Should a player be notified about an item foun

Config.DivingZones = {
    [1] = {
        label = "Salvage Area",  -- Label of Blip on the Map
        coords = vector3(-2663.7170, -811.7948, -25.2107), -- Coordinates of Salvage Area
        zoneRadius = 350.0, -- Radius of the Salvage Area
        sprite = 404, -- Sprite for the Blip of the Salvage Area
        color = 1, -- Color of the Salvage Area Blip
        radiusColor = 1, -- Color of the Salvage Area Radius
        scale = 0.8 -- Scale of the Salvage Area Blip
    },
    [2] = {
        label = "Salvage Area",
        coords = vector3(3696.3650, 6103.8218, -0.2148),
        zoneRadius = 350.0,
        sprite = 404,
        color = 1,
        radiusColor = 1,
        scale = 0.8
    }
}

-- Strings --

Config.Strings = {
    apply_oxygentank = 'Putting on Scuba Gear',
    cancel_oxygentank = 'Putting on Scuba Gear Cancelled',
    applied_scubagear = 'You put on the diving mask & secure the oxygen tank.',
    already_applied = 'You are already wearing scuba gear!',
    item_found = 'You have found ',
    noti_title1 = 'Oxygen Tank',
    noti_title2 = 'Diving'
}