local Framework = Config.Framework == 'ESX' and exports['es_extended']:getSharedObject() or exports['qb-core']:GetCoreObject()
local PlayerProgress = {}

-- Database initialization
CreateThread(function()
   MySQL.query([[
       CREATE TABLE IF NOT EXISTS recycling_progress (
           identifier VARCHAR(50) PRIMARY KEY,
           level INT DEFAULT 0,
           xp INT DEFAULT 0,
           daily_recycles INT DEFAULT 0,
           last_reset TIMESTAMP DEFAULT CURRENT_TIMESTAMP
       )
   ]])
end)

-- Player data management
local function GetIdentifier(source)
   if Config.Framework == 'ESX' then
       local xPlayer = Framework.GetPlayerFromId(source)
       while not xPlayer do
           Wait(100)
           xPlayer = Framework.GetPlayerFromId(source)
       end
       return xPlayer.identifier
   else
       local Player = Framework.Functions.GetPlayer(source)
       return Player.PlayerData.citizenid
   end
end

local function LoadPlayerData(source)
   local identifier = GetIdentifier(source)
   if not identifier then return end

   MySQL.query('SELECT * FROM recycling_progress WHERE identifier = ?', {identifier}, 
   function(result)
       if result[1] then
           PlayerProgress[source] = {
               level = result[1].level,
               xp = result[1].xp
           }
       else
           PlayerProgress[source] = { level = 0, xp = 0 }
           MySQL.insert('INSERT INTO recycling_progress (identifier) VALUES (?)', {identifier})
       end
       TriggerClientEvent('gld-recycling:client:updateProgress', source, PlayerProgress[source].level, PlayerProgress[source].xp)
   end)
end

local function SavePlayerData(source)
   if not PlayerProgress[source] then return end
   
   local identifier = GetIdentifier(source)
   if not identifier then return end

   MySQL.update('UPDATE recycling_progress SET level = ?, xp = ? WHERE identifier = ?', {
       PlayerProgress[source].level,
       PlayerProgress[source].xp,
       identifier
   })
end

local function Notify(source, msg, type)
    if Config.Framework == 'ESX' then
        TriggerClientEvent('esx:showNotification', source, msg)
    elseif Config.Framework == 'QBCORE' then
        TriggerClientEvent('QBCore:Notify', source, msg, type)
    else
        print('^1Erreur : Framework non configuré pour les notifications.^0')
    end
end

-- Check level up
local function CheckLevelUp(source)
   if not PlayerProgress[source] then return false end

   local nextLevel = PlayerProgress[source].level + 1
   if Config.Levels[nextLevel] and PlayerProgress[source].xp >= Config.Levels[nextLevel].requireXP then
       PlayerProgress[source].level = nextLevel
       PlayerProgress[source].xp = 0
       Notify(source, 'Niveau supérieur! Niveau ' .. nextLevel, 'success')
       return true
   end
   return false
end

-- Process recycling
RegisterNetEvent('gld-recycling:server:processItem', function(itemName, amount, zoneBonus)
   local src = source
   local identifier = GetIdentifier(src)
   if not identifier then return end

   if Config.Framework == 'ESX' then
       if Config.UseOxInventory then
           local count = exports.ox_inventory:GetItem(src, itemName, nil, true)
           if count < amount then return end
           
           exports.ox_inventory:RemoveItem(src, itemName, amount)
       else
           local xPlayer = Framework.GetPlayerFromId(src)
           local item = xPlayer.getInventoryItem(itemName)
           if not item or item.count < amount then return end
           
           xPlayer.removeInventoryItem(itemName, amount)
       end
   else
       local Player = Framework.Functions.GetPlayer(src)
       if not Player.Functions.RemoveItem(itemName, amount) then return end
   end

   -- Give rewards with bonus
   local rewards = Config.RecyclableItems[itemName].rewards
   if not rewards then return end

   local eventMultiplier = Config.Events.doubleRewards.enabled and Config.Events.doubleRewards.multiplier or 1.0
   local totalMultiplier = (zoneBonus or 1.0) * eventMultiplier

   for _, reward in pairs(rewards) do
       local rewardAmount = math.floor(math.random(reward.min, reward.max) * amount * totalMultiplier)
       
       if Config.Framework == 'ESX' then
           if Config.UseOxInventory then
               exports.ox_inventory:AddItem(src, reward.item, rewardAmount)
           else
               local xPlayer = Framework.GetPlayerFromId(src)
               xPlayer.addInventoryItem(reward.item, rewardAmount)
               Notify(source, 'Tu à reçu : '  .. reward.item .. ' x ['  .. rewardAmount ..']' ,'success')

           end
       else
           local Player = Framework.Functions.GetPlayer(src)
           Player.Functions.AddItem(reward.item, rewardAmount)
           Notify(source, 'Tu à reçu : '  .. reward.item .. ' x ['  .. rewardAmount ..']' ,'success')
           
       end
   end

   -- Add XP
   if not PlayerProgress[src] then
       PlayerProgress[src] = { level = 0, xp = 0 }
   end

   PlayerProgress[src].xp = PlayerProgress[src].xp + (amount * 10)
   
   -- Check level up and save
   CheckLevelUp(src)
   SavePlayerData(src)
   
   -- Update client
   TriggerClientEvent('gld-recycling:client:updateProgress', src, PlayerProgress[src].level, PlayerProgress[src].xp)
end)

-- Get player progress
RegisterNetEvent('gld-recycling:server:getPlayerProgress', function()
   local src = source
   LoadPlayerData(src)
end)

-- Framework events
if Config.Framework == 'ESX' then
   RegisterNetEvent('esx:playerLoaded', function(source)
       LoadPlayerData(source)
   end)
else
   RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
       LoadPlayerData(Player.PlayerData.source)
   end)
end

-- Player dropped
AddEventHandler('playerDropped', function()
   local src = source
   if PlayerProgress[src] then
       SavePlayerData(src)
       PlayerProgress[src] = nil
   end
end)

-- Admin commands
RegisterCommand('setrecyclelevel', function(source, args)
   local target = tonumber(args[1])
   local level = tonumber(args[2])
   
   if Config.Framework == 'ESX' then
       local xPlayer = Framework.GetPlayerFromId(source)
       if xPlayer.getGroup() ~= 'admin' then return end
   else
       local Player = Framework.Functions.GetPlayer(source)
       if Player.PlayerData.group ~= 'admin' then return end
   end
   
   if not target or not level or not Config.Levels[level] then return end

   if PlayerProgress[target] then
       PlayerProgress[target].level = level
       PlayerProgress[target].xp = 0
       SavePlayerData(target)
       TriggerClientEvent('gld-recycling:client:updateProgress', target, level, 0)
       TriggerClientEvent('gld-recycling:client:levelUp', target, level)
   end
end)