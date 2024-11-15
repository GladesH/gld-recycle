-- client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentLevel = 0
local currentXP = 0
local todayRecycles = 0

-- Création des points de recyclage
CreateThread(function()
    for _, location in pairs(Config.Locations) do
        local model = GetHashKey(Config.RecyclingBin.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        
        local obj = CreateObject(model, location.coords.x, location.coords.y, location.coords.z-1.0, false, false, false)
        SetEntityHeading(obj, location.heading)
        FreezeEntityPosition(obj, true)
        SetEntityAsMissionEntity(obj, true, true)
    end
end)

-- Target
CreateThread(function()
    if Config.target.framework.target == 'qb-target' then
        exports['qb-target']:AddTargetModel(Config.RecyclingBin.model, {
            options = {
                {
                    type = "client",
                    icon = 'fas fa-recycle',
                    label = Config.RecyclingBin.label,
                    action = function()
                        OpenRecyclingMenu()
                    end
                }
            },
            distance = 2.5
        })
        elseif Config.target.framework.target == 'ox_target' then
            exports.ox_target:addModel(Config.RecyclingBin.model, {
                {
                    name = 'recycling_bin',
                    label = Config.RecyclingBin.label,
                    icon = 'fas fa-recycle',
                    onSelect = function()
                        OpenRecyclingMenu()
                    end
                }
            })
        end
end)

-- Effets de recyclage
local function PlayRecycleEffect(entity)
    local coords = GetEntityCoords(entity)
    
    -- Particules
    UseParticleFxAssetNextCall("core")
    local particle = StartParticleFxLoopedAtCoord("ent_amb_smoke_factory_white", 
        coords.x, coords.y, coords.z + 1.0,
        0.0, 0.0, 0.0, 
        1.0, false, false, false, false)
    
    -- Son
    PlaySoundFromCoord(-1, "COLLECTION_SCORE", coords.x, coords.y, coords.z, "GTAO_Magnate_Boss_Modes_Soundset", false, 20, false)
    
    Wait(Config.ProcessTime * 1000)
    StopParticleFxLooped(particle, 0)
end

-- Mini-jeu de recyclage
local function StartRecyclingMinigame()
    local success = exports['ps-ui']:Circle(function(success)
        if success then
            return true
        else
            return false
        end
    end, 2, 20)
    return success
end

-- Vérifier si le joueur est dans une zone spéciale
local function GetZoneBonus()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local bonus = 1.0

    for zoneName, zone in pairs(Config.SpecialZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            bonus = zone.bonus
            break
        end
    end

    return bonus
end

-- Interface utilisateur
function OpenRecyclingMenu()
    local inventory = QBCore.Functions.GetPlayerData().items
    local recyclableItems = {}
    
    for k, v in pairs(inventory) do
        if Config.RecyclableItems[v.name] then
            local rewards = Config.RecyclableItems[v.name].rewards
            -- Ajout des labels pour chaque récompense
            for _, reward in pairs(rewards) do
                local item = QBCore.Shared.Items[reward.item]
                reward.label = item and item.label or reward.item
            end
            
            v.rewards = rewards
            table.insert(recyclableItems, v)
        end
    end

    local menuData = {
        action = "openMenu",
        items = recyclableItems,
        level = currentLevel,
        xp = currentXP,
        maxXP = Config.RecyclingLevels[currentLevel + 1] and Config.RecyclingLevels[currentLevel + 1].requireXP or 0,
        maxItems = Config.RecyclingLevels[currentLevel].maxItems
    }

    SetNuiFocus(true, true)
    SendNUIMessage(menuData)
end

-- Traitement du recyclage
RegisterNetEvent('qb-recycling:client:processItem', function(itemName, amount)
    if not Config.RecyclableItems[itemName] then return end
 
    -- Vérifier les limites de niveau
    local maxItems = Config.RecyclingLevels[currentLevel] and Config.RecyclingLevels[currentLevel].maxItems or 5
    if amount > maxItems then
        QBCore.Functions.Notify('Vous ne pouvez pas recycler autant d\'items à votre niveau actuel', 'error')
        return
    end
 
    -- Trouver le recycleur le plus proche
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestBin = nil
    local closestDistance = 1000
    
    for _, obj in pairs(GetGamePool('CObject')) do
        if GetEntityModel(obj) == GetHashKey(Config.RecyclingBin.model) then
            local distance = #(playerCoords - GetEntityCoords(obj))
            if distance < closestDistance then
                closestDistance = distance
                closestBin = obj
            end
        end
    end
 
    QBCore.Functions.Progressbar("recycling_item", "Recyclage en cours...", 
        Config.ProcessTime * 1000, 
        false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mini@repair",
            anim = "fixing_a_ped",
            flags = 49,
        }, {}, {}, function() -- Done
            if closestBin then
                PlayRecycleEffect(closestBin)
            end
            TriggerServerEvent('qb-recycling:server:processItem', itemName, amount)
            Wait(500)
            OpenRecyclingMenu()
    end)
 end)

-- Événements pour la progression
RegisterNetEvent('qb-recycling:client:updateProgress', function(level, xp)
    currentLevel = level
    currentXP = xp
end)

RegisterNetEvent('qb-recycling:client:updateDailyProgress', function(recycles)
    todayRecycles = recycles
end)

-- Callbacks NUI
RegisterNUICallback('recycleItem', function(data, cb)
    TriggerEvent('qb-recycling:client:processItem', data.item, data.amount)
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Initialisation du joueur
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('qb-recycling:server:getPlayerProgress')
end)

-- Commande admin pour ajouter un recycleur
RegisterCommand('addrecycler', function()
    if QBCore.Functions.GetPlayerData().group == 'admin' then
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        print(string.format("coords = vector3(%s, %s, %s),", coords.x, coords.y, coords.z))
        print(string.format("heading = %s", heading))
    end
end)