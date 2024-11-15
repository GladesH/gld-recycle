-- server/server.lua
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerProgress = {}
local DailyRecycles = {}

-- Charger/Sauvegarder les données des joueurs
local function LoadPlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    exports.oxmysql:execute('SELECT * FROM recycling_progress WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    }, function(result)
        if result[1] then
            PlayerProgress[source] = {
                level = result[1].level,
                xp = result[1].xp
            }
            DailyRecycles[source] = result[1].daily_recycles
        else
            PlayerProgress[source] = { level = 0, xp = 0 }
            DailyRecycles[source] = 0
            exports.oxmysql:insert('INSERT INTO recycling_progress (citizenid, level, xp, daily_recycles) VALUES (?, ?, ?, ?)', {
                Player.PlayerData.citizenid,
                0,
                0,
                0
            })
        end
        TriggerClientEvent('qb-recycling:client:updateProgress', source, PlayerProgress[source].level, PlayerProgress[source].xp)
        TriggerClientEvent('qb-recycling:client:updateDailyProgress', source, DailyRecycles[source])
    end)
end

-- Sauvegarder les données d'un joueur
local function SavePlayerData(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player or not PlayerProgress[source] then return end

    exports.oxmysql:execute('UPDATE recycling_progress SET level = ?, xp = ?, daily_recycles = ? WHERE citizenid = ?', {
        PlayerProgress[source].level,
        PlayerProgress[source].xp,
        DailyRecycles[source],
        Player.PlayerData.citizenid
    })
end

-- Ajouter de l'XP à un joueur
local function AddPlayerXP(source, amount)
    if not PlayerProgress[source] then
        PlayerProgress[source] = { level = 0, xp = 0 }
    end

    PlayerProgress[source].xp = PlayerProgress[source].xp + amount

    -- Vérifier si le joueur peut monter de niveau
    local nextLevel = PlayerProgress[source].level + 1
    if Config.RecyclingLevels[nextLevel] and PlayerProgress[source].xp >= Config.RecyclingLevels[nextLevel].requireXP then
        PlayerProgress[source].level = nextLevel
        PlayerProgress[source].xp = 0
        TriggerClientEvent('QBCore:Notify', source, 'Niveau supérieur! Vous êtes maintenant niveau ' .. nextLevel, 'success')
    end

    TriggerClientEvent('qb-recycling:client:updateProgress', source, PlayerProgress[source].level, PlayerProgress[source].xp)
    SavePlayerData(source)
end

-- Vérifier les récompenses quotidiennes
local function CheckDailyRewards(source)
    if not Config.DailyRecycling.enabled or not DailyRecycles[source] then return end

    if DailyRecycles[source] >= Config.DailyRecycling.requiredRecycles then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end

        for _, reward in pairs(Config.DailyRecycling.rewards) do
            if reward.item then
                Player.Functions.AddItem(reward.item, reward.amount)
                TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[reward.item], "add", reward.amount)
            elseif reward.money then
                Player.Functions.AddMoney(reward.money, reward.amount)
            end
        end

        DailyRecycles[source] = 0
        TriggerClientEvent('QBCore:Notify', source, 'Vous avez reçu vos récompenses quotidiennes!', 'success')
        TriggerClientEvent('qb-recycling:client:updateDailyProgress', source, DailyRecycles[source])
        SavePlayerData(source)
    end
end

-- Événement pour obtenir la progression du joueur
RegisterNetEvent('qb-recycling:server:getPlayerProgress', function()
    local src = source
    LoadPlayerData(src)
end)

-- Événement de recyclage
RegisterNetEvent('qb-recycling:server:processItem', function(itemName, amount, bonusMultiplier)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local item = Config.RecyclableItems[itemName]
    if not item then return end

    -- Vérifier si le joueur a l'item
    if Player.Functions.RemoveItem(itemName, amount) then
        -- S'assurer que le joueur a des données de progression
        if not PlayerProgress[src] then
            PlayerProgress[src] = { level = 0, xp = 0 }
            DailyRecycles[src] = 0
        end

        -- Calculer les bonus
        local levelMultiplier = (Config.RecyclingLevels[PlayerProgress[src].level] and Config.RecyclingLevels[PlayerProgress[src].level].multiplier) or 1.0
        local eventMultiplier = Config.Events.doubleRewards.enabled and Config.Events.doubleRewards.multiplier or 1.0
        local totalMultiplier = (bonusMultiplier or 1.0) * levelMultiplier * eventMultiplier

        -- Attribution des récompenses
        for _, reward in pairs(item.rewards) do
            local rewardAmount = math.floor(math.random(reward.min, reward.max) * amount * totalMultiplier)
            Player.Functions.AddItem(reward.item, rewardAmount)
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], "add", rewardAmount)
        end

        -- Ajouter XP et vérifier daily
        AddPlayerXP(src, amount * 10)
        DailyRecycles[src] = (DailyRecycles[src] or 0) + amount
        CheckDailyRewards(src)
        
        -- Vérifier les items spéciaux
        if Config.Events.specialItems then
            for specialItem, data in pairs(Config.Events.specialItems) do
                if math.random(100) <= data.chance then
                    for _, reward in pairs(data.rewards) do
                        local specialAmount = math.random(reward.min, reward.max)
                        Player.Functions.AddItem(reward.item, specialAmount)
                        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], "add", specialAmount)
                        TriggerClientEvent('QBCore:Notify', src, 'Item spécial trouvé!', 'success')
                    end
                end
            end
        end
        
        -- Mise à jour du client
        TriggerClientEvent('qb-recycling:client:updateDailyProgress', src, DailyRecycles[src])
        
        -- Notification de succès
        TriggerClientEvent('QBCore:Notify', src, 'Items recyclés avec succès!', 'success')
    end
end)

-- Événements QB-Core
RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    LoadPlayerData(Player.PlayerData.source)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if PlayerProgress[src] then
        SavePlayerData(src)
        PlayerProgress[src] = nil
        DailyRecycles[src] = nil
    end
end)

-- Reset quotidien
CreateThread(function()
    while true do
        Wait(1000 * 60 * 60) -- Vérifier chaque heure
        local currentTime = os.date("*t")
        
        if currentTime.hour == 0 then -- Minuit
            for src in pairs(DailyRecycles) do
                DailyRecycles[src] = 0
                TriggerClientEvent('qb-recycling:client:updateDailyProgress', src, 0)
                SavePlayerData(src)
            end
        end
    end
end)