-- ox_inventory item definitions for bt-diving
-- Add the contents of this table into your ox_inventory/data/items.lua

return {
    ['oxygentank'] = {
        label = 'Oxygen Tank',
        weight = 5000,
        stack = false,
        close = true,
        description = 'A scuba diving oxygen tank. Strapping this on lets you breathe underwater.',
        server = {
            export = 'bt-diving.oxygentank',
        },
    },

    -- Salvage loot --------------------------------------------------------

    ['trash'] = {
        label = 'Trash',
        weight = 100,
        stack = true,
        close = false,
        description = 'Just rubbish dredged up from the ocean floor.',
    },

    ['fishingrod'] = {
        label = 'Fishing Rod',
        weight = 1500,
        stack = false,
        close = false,
        description = 'A fishing rod recovered from the seabed. Needs a clean-up.',
    },

    ['plastic'] = {
        label = 'Plastic Scrap',
        weight = 200,
        stack = true,
        close = false,
        description = 'Pieces of plastic salvaged from the ocean floor.',
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 300,
        stack = true,
        close = false,
        description = 'Salvaged rubber material. Useful for crafting.',
    },

    ['steel'] = {
        label = 'Steel',
        weight = 1000,
        stack = true,
        close = false,
        description = 'A chunk of steel recovered from a sunken wreck.',
    },

    ['scrapmetal'] = {
        label = 'Scrap Metal',
        weight = 800,
        stack = true,
        close = false,
        description = 'Assorted scrap metal pulled from the ocean floor.',
    },

    ['iron'] = {
        label = 'Iron',
        weight = 900,
        stack = true,
        close = false,
        description = 'Raw iron salvaged from underwater debris.',
    },

    ['nylonrope'] = {
        label = 'Nylon Rope',
        weight = 400,
        stack = true,
        close = false,
        description = 'A length of nylon rope salvaged from the seabed.',
    },

    ['pliers'] = {
        label = 'Pliers',
        weight = 500,
        stack = false,
        close = false,
        description = 'A pair of pliers recovered from a sunken vessel.',
    },

    ['electronics'] = {
        label = 'Electronics',
        weight = 600,
        stack = true,
        close = false,
        description = 'Waterlogged electronic components. May still be salvageable.',
    },

    ['blowtorch'] = {
        label = 'Blowtorch',
        weight = 2000,
        stack = false,
        close = false,
        description = 'A blowtorch dredged up from the ocean floor.',
    },

    ['x_device'] = {
        label = 'Unknown Device',
        weight = 300,
        stack = false,
        close = false,
        description = 'An unusual device found in an underwater capsule. Its purpose is unclear.',
    },

    ['glass_cutter'] = {
        label = 'Glass Cutter',
        weight = 400,
        stack = false,
        close = false,
        description = 'A precision glass-cutting tool found on the ocean floor.',
    },
}
