Config = {}

-- Framework Configuration
Config.Framework = 'ESX' -- 'ESX' ou 'QBCORE'
Config.Target = 'ox' -- 'ox' ou 'qb'
Config.UseOxInventory = true -- true pour ox_inventory, false pour l'inventaire natif

Config.RecyclableItems = {
   ['fixkit'] = {
       rewards = {
           { item = 'iron', min = 2, max = 4 },
           { item = 'leather', min = 1, max = 2 }
       }
   },
   ['WEAPON_BAT'] = {
       rewards = {
           { item = 'iron', min = 4, max = 6 },
           { item = 'rubber', min = 1, max = 2 }
       }
   },
   ['WEAPON_HAMMER'] = {
       rewards = {
           { item = 'iron', min = 3, max = 5 },
           { item = 'wood', min = 1, max = 2 }
       }
   },
   ['WEAPON_HATCHET'] = {
       rewards = {
           { item = 'iron', min = 4, max = 6 },
           { item = 'wood', min = 2, max = 3 }
       }
   },
   ['WEAPON_KNUCKLE'] = {
       rewards = {
           { item = 'iron', min = 2, max = 4 }
       }
   },
   ['WEAPON_KNIFE'] = {
       rewards = {
           { item = 'iron', min = 2, max = 3 },
           { item = 'plastic', min = 1, max = 2 }
       }
   },
   ['WEAPON_MACHETE'] = {
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
   }
}

Config.RecyclingBin = {
   model = 'prop_recyclebin_04_b',
   label = 'Recycler des matériaux'
}

Config.Locations = {
   {
       coords = vector3(-353.0373, -1542.9069, 27.7195),
       heading = 273.5285
   }
}

Config.Levels = {
   [0] = { maxItems = 5, requireXP = 0 },
   [1] = { maxItems = 10, requireXP = 100 },
   [2] = { maxItems = 15, requireXP = 250 },
   [3] = { maxItems = 20, requireXP = 500 },
   [4] = { maxItems = 25, requireXP = 1000000000 }
}

Config.Events = {
   doubleRewards = {
       enabled = false,
       multiplier = 2.0
   }
}

Config.SpecialZones = {
   ['factory'] = {
       coords = vector3(-1164.7, -2018.5, 13.2),
       radius = 50.0,
       bonus = 1.5,
       specializedFor = {'iron', 'electronics'}
   }
}

Config.ProcessTime = 5000

Config.Translations = {
   ['recycling_in_progress'] = 'Recyclage en cours...',
   ['cant_carry'] = 'Vous ne pouvez pas porter autant d\'objets',
   ['level_up'] = 'Niveau supérieur! Niveau %s',
   ['special_zone'] = 'Zone spéciale! Bonus x%s',
   ['max_items_reached'] = 'Vous ne pouvez pas recycler autant d\'items à votre niveau actuel'
}