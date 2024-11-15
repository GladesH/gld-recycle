-- config.lua
Config = {}

Config.target = {
    framework = {
        target = 'ox_target', -- 'ox_target' ou 'qb-target'
    }
}

-- Configuration du point de recyclage
Config.RecyclingBin = {
    model = 'prop_recyclebin_04_b',
    label = 'Recycler des matériaux'
}

Config.RecyclableItems = {
    ['weapon_dagger'] = {
        rewards = {
            { item = 'iron', min = 2, max = 4 },
            { item = 'leather', min = 1, max = 2 }
        }
    },
    ['weapon_golfclub'] = {
        rewards = {
            { item = 'iron', min = 4, max = 6 },
            { item = 'rubber', min = 1, max = 2 }
        }
    },
    ['weapon_hammer'] = {
        rewards = {
            { item = 'iron', min = 3, max = 5 },
            { item = 'wood', min = 1, max = 2 }
        }
    },
    ['weapon_hatchet'] = {
        rewards = {
            { item = 'iron', min = 4, max = 6 },
            { item = 'plastic', min = 2, max = 4 },
            { item = 'wood', min = 2, max = 3 }
        }
    },
    ['weapon_knuckle'] = {
        rewards = {
            { item = 'iron', min = 2, max = 4 }
        }
    },
    ['weapon_knife'] = {
        rewards = {
            { item = 'iron', min = 2, max = 3 },
            { item = 'plastic', min = 1, max = 2 }
        }
    },
    ['weapon_machete'] = {
        rewards = {
            { item = 'iron', min = 5, max = 7 },
            { item = 'plastic', min = 1, max = 2 }
        }
    },
    ['lockpick'] = {
        rewards = {
            { item = 'iron', min = 1, max = 2 },
            { item = 'plastic', min = 1, max = 1 }
        }
    },
    ['electronickit'] = {
        rewards = {
            { item = 'copper', min = 3, max = 5 },
            { item = 'plastic', min = 2, max = 4 },
            { item = 'electronics', min = 2, max = 4 }
        }
    },
    ['repairkit'] = {
        rewards = {
            { item = 'iron', min = 2, max = 4 },
            { item = 'plastic', min = 1, max = 2 },
            { item = 'electronics', min = 1, max = 2 }
        }
    },
    ['fixkit'] = {
        rewards = {
            { item = 'iron', min = 2, max = 3 },
            { item = 'plastic', min = 1, max = 2 }
        }
    },
    ['firstaid'] = {
        rewards = {
            { item = 'plastic', min = 2, max = 4 },
            { item = 'cloth', min = 3, max = 5 }
        }
    },
    ['bandage'] = {
        rewards = {
            { item = 'cloth', min = 1, max = 2 }
        }
    },
    ['ifaks'] = {
        rewards = {
            { item = 'plastic', min = 2, max = 3 },
            { item = 'cloth', min = 2, max = 4 }
        }
    },
    ['gps'] = {
        rewards = {
            { item = 'electronics', min = 1, max = 2 },
            { item = 'plastic', min = 1, max = 2 }
        }
    },
    ['backpack1'] = {
        rewards = {
            { item = 'cloth', min = 4, max = 6 },
            { item = 'plastic', min = 2, max = 3 }
        }
    },
    ['backpack2'] = {
        rewards = {
            { item = 'cloth', min = 6, max = 8 },
            { item = 'plastic', min = 3, max = 4 }
        }
    }
}

-- Positions des points de recyclage
Config.Locations = {
    {
        coords = vector3(-353.0373, -1542.9069, 27.7195),
        heading = 273.5285
    },
    {
        coords = vector3(5123.85, -5113.78, 2.13),
        heading = 82.27
    },
    {
        coords = vector3(48.6, -1605.01, 29.6),
        heading = 136.98
    },
    {
        coords = vector3(-14.23, -1439.15, 34.15),
        heading = 264.77
    },
    {
        coords = vector3(4926.72, -5193.03, 2.49),
        heading = 150.09
    },
    {
        coords = vector3(124.16, -1543.82, 29.33),
        heading = 140.94
    },
    {
        coords = vector3(305.21, -1432.16, 29.9),
        heading = 321.15
    },
    {
        coords = vector3(483.37, -3383.74, 6.07),
        heading = 172.69
    }
}

-- Système de niveaux
Config.RecyclingLevels = {
    [0] = { multiplier = 1.0, maxItems = 5 },
    [1] = { multiplier = 1.2, maxItems = 7, requireXP = 100 },
    [2] = { multiplier = 1.4, maxItems = 10, requireXP = 250 },
    [3] = { multiplier = 1.6, maxItems = 15, requireXP = 500 },
    [4] = { multiplier = 1.8, maxItems = 20, requireXP = 750 },
    [5] = { multiplier = 2.0, maxItems = 25, requireXP = 950 },
    [6] = { multiplier = 2.2, maxItems = 30, requireXP = 1150 },
    [7] = { multiplier = 2.4, maxItems = 35, requireXP = 1350 },
    [8] = { multiplier = 2.5, maxItems = 40, requireXP = 1550 },
    [9] = { multiplier = 2.6, maxItems = 45, requireXP = 1750 },
    [10] = { multiplier = 2.7, maxItems = 50, requireXP = 1950 },
    [11] = { multiplier = 2.8, maxItems = 60, requireXP = 2250 },
    [12] = { multiplier = 2.9, maxItems = 70, requireXP = 2450 },
    [13] = { multiplier = 3.0, maxItems = 80, requireXP = 2750 },
    [14] = { multiplier = 3.1, maxItems = 90, requireXP = 3000 },
    [15] = { multiplier = 3.2, maxItems = 100, requireXP = 3250 },
    [16] = { multiplier = 3.4, maxItems = 105, requireXP = 3500 },
    [17] = { multiplier = 3.5, maxItems = 110, requireXP = 3750 },
    [18] = { multiplier = 3.6, maxItems = 115, requireXP = 4000 },
    [19] = { multiplier = 3.7, maxItems = 125, requireXP = 4250 },
    [20] = { multiplier = 3.8, maxItems = 135, requireXP = 4500 },
    [21] = { multiplier = 3.9, maxItems = 145, requireXP = 5000 },
    [22] = { multiplier = 4.0, maxItems = 150, requireXP = 10000 },

}

-- Événements spéciaux
Config.Events = {
    doubleRewards = {
        enabled = false,
        multiplier = 2.0
    },
    specialItems = {
        ['laptop'] = {
            rewards = {
                { item = 'gold', min = 1, max = 2 },
                { item = 'electronics', min = 5, max = 8 }
            },
            chance = 5
        }
    }
}

-- Configuration du recyclage en masse
Config.BulkRecycling = {
    enabled = true,
    maxBulkItems = 50,
    timeMultiplier = 0.5
}

-- Zones spéciales
Config.SpecialZones = {
    ['factory'] = {
        coords = vector3(-1164.7, -2018.5, 13.2),
        radius = 50.0,
        bonus = 1.5,
        specializedFor = {'iron', 'electronics'}
    }
}

-- Temps de recyclage en secondes
Config.ProcessTime = 5

-- Notifications personnalisées
Config.CustomNotifications = {
    levelUp = {
        title = "Niveau Supérieur!",
        description = "Vous êtes maintenant niveau %d en recyclage!",
        type = "success"
    },
    rareMaterial = {
        title = "Matériau Rare!",
        description = "Vous avez trouvé %s en recyclant!",
        type = "info"
    }
}

-- Récompenses quotidiennes
Config.DailyRecycling = {
    enabled = true,
    rewards = {
        { item = 'old_money', amount = 600 }
    },
    requiredRecycles = 1
}