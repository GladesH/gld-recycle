-- bridge/bridge.lua
Framework = {}

-- Initialisation du Framework
CreateThread(function()
    if Config.Framework == 'ESX' then
        while not ESX do
            ESX = exports['es_extended']:getSharedObject()
            Wait(100)
        end
        Framework.object = ESX
    else
        Framework.object = exports['qb-core']:GetCoreObject()
    end
end)

Framework.GetPlayerData = function()
    if Config.Framework == 'ESX' then
        return Framework.object.GetPlayerData()
    else
        return Framework.object.Functions.GetPlayerData()
    end
end



Framework.GetInventoryItems = function()
    local items = {}
    
    if Config.Framework == 'ESX' then
        if Config.UseOxInventory then
            local inventory = exports.ox_inventory:GetPlayerItems()
            for _, item in pairs(inventory) do
                if Config.RecyclableItems[item.name] then
                    table.insert(items, {
                        name = item.name,
                        label = item.metadata and item.metadata.label or item.label,
                        amount = item.count,
                        rewards = Config.RecyclableItems[item.name].rewards
                    })
                end
            end
        else
            local inventory = ESX.GetPlayerData().inventory
            for _, item in pairs(inventory) do
                if item.count > 0 and Config.RecyclableItems[item.name] then
                    table.insert(items, {
                        name = item.name,
                        label = item.label,
                        amount = item.count,
                        rewards = Config.RecyclableItems[item.name].rewards
                    })
                end
            end
        end
    else
               -- Vérification si QBCore est bien initialisé
               if not Framework.object then
                print("^1Erreur : QBCore n'est pas chargé correctement !^0")
                return items
            end
    
            local Player = Framework.object.Functions.GetPlayerData()
            for _, item in pairs(Player.items) do
                if item.amount > 0 and Config.RecyclableItems[item.name] then
                    table.insert(items, {
                        name = item.name,
                        label = item.label,
                        amount = item.amount,
                        rewards = Config.RecyclableItems[item.name].rewards
                    })
                end
            end
        end
        
        return items
    end

    Framework.Notify = function(source, msg, type)
        if Config.Framework == 'ESX' then
            TriggerClientEvent('esx:showNotification', source, msg)
        elseif Config.Framework == 'QBCORE' then
            TriggerClientEvent('QBCore:Notify', source, msg, type)
        else
            print('^1Erreur : Framework non configuré pour les notifications.^0')
        end
    end
    

Framework.RemoveItem = function(source, item, amount)
    if Config.Framework == 'ESX' then
        if Config.UseOxInventory then
            return exports.ox_inventory:RemoveItem(source, item, amount)
        else
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer.getInventoryItem(item).count >= amount then
                xPlayer.removeInventoryItem(item, amount)
                return true
            end
            return false
        end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.Functions.RemoveItem(item, amount)
    end
end

Framework.AddItem = function(source, item, amount)
    if Config.Framework == 'ESX' then
        if Config.UseOxInventory then
            exports.ox_inventory:AddItem(source, item, amount)
        else
            local xPlayer = ESX.GetPlayerFromId(source)
            xPlayer.addInventoryItem(item, amount)
        end
    else
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('qb-inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', amount)
    end
end

Framework.IsAdmin = function(source)
    if Config.Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        local group = xPlayer.getGroup()
        return group == 'admin' or group == 'superadmin'
    else
        local Player = QBCore.Functions.GetPlayer(source)
        return Player.PlayerData.group == 'admin'
    end
end

return Framework