local currentLevel = 0
local currentXP = 0
local isProcessing = false

-- Create recycling points
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

-- Target setup
CreateThread(function()
    if Config.Target == 'ox' then
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
    else
        exports['qb-target']:AddTargetModel(Config.RecyclingBin.model, {
            options = {
                {
                    type = "client",
                    event = "gld-recycling:client:openMenu",
                    icon = "fas fa-recycle",
                    label = Config.RecyclingBin.label,
                }
            },
            distance = 2.5,
        })
    end
end)

RegisterNetEvent('gld-recycling:client:openMenu', function()
    OpenRecyclingMenu()
end)

-- Effects
local function PlayRecycleEffect(entity)
    local coords = GetEntityCoords(entity)
    
    UseParticleFxAssetNextCall("core")
    local particle = StartParticleFxLoopedAtCoord("ent_amb_smoke_factory_white", 
        coords.x, coords.y, coords.z + 1.0,
        0.0, 0.0, 0.0, 
        1.0, false, false, false, false)
    
    PlaySoundFromCoord(-1, "COLLECTION_SCORE", coords.x, coords.y, coords.z, "GTAO_Magnate_Boss_Modes_Soundset", false, 20, false)
    
    Wait(Config.ProcessTime)
    StopParticleFxLooped(particle, 0)
end

-- Get zone bonus
local function GetZoneBonus()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local bonus = 1.0

    for zoneName, zone in pairs(Config.SpecialZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            bonus = zone.bonus
            Notify('Zone spéciale! Bonus x' .. bonus)
            break
        end
    end

    return bonus
end

function OpenRecyclingMenu()
    if isProcessing then return end

    local items = Framework.GetInventoryItems()
    
    local menuData = {
        action = "openMenu",
        items = items,
        level = currentLevel,
        xp = currentXP,
        maxXP = Config.Levels[currentLevel + 1] and Config.Levels[currentLevel + 1].requireXP or 0,
        maxItems = Config.Levels[currentLevel] and Config.Levels[currentLevel].maxItems or 5
    }

    SetNuiFocus(true, true)
    SendNUIMessage(menuData)
end

-- Process recycling
RegisterNUICallback('recycleItem', function(data, cb)
    if isProcessing then return end
    isProcessing = true

    local itemName = data.item
    local amount = tonumber(data.amount)

    -- Get closest bin
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

    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)

    if lib then
        if lib.progressBar({
            duration = Config.ProcessTime,
            label = 'Recyclage en cours...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            }
        }) then
            if closestBin then
                PlayRecycleEffect(closestBin)
            end
            
            local zoneBonus = GetZoneBonus()
            TriggerServerEvent('gld-recycling:server:processItem', itemName, amount, zoneBonus)
            Wait(500)
            OpenRecyclingMenu()
        end
    else
        if Config.Framework == 'ESX' then
            Framework.object.ShowProgress(Config.ProcessTime, 'Recyclage en cours...')
        else
            QBCore.Functions.Progressbar("recycling", 'Recyclage en cours...', Config.ProcessTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            })
        end
        
        Wait(Config.ProcessTime)
        if closestBin then
            PlayRecycleEffect(closestBin)
        end
        
        local zoneBonus = GetZoneBonus()
        TriggerServerEvent('gld-recycling:server:processItem', itemName, amount, zoneBonus)
        Wait(500)
        OpenRecyclingMenu()
    end

    ClearPedTasks(PlayerPedId())
    isProcessing = false
    if cb then cb('ok') end
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Progress events
RegisterNetEvent('gld-recycling:client:updateProgress', function(level, xp)
    currentLevel = level
    currentXP = xp
end)

-- Framework loaded event
if Config.Framework == 'ESX' then
    RegisterNetEvent('esx:playerLoaded', function()
        TriggerServerEvent('gld-recycling:server:getPlayerProgress')
    end)
else
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        TriggerServerEvent('gld-recycling:server:getPlayerProgress')
    end)
end

-- Escape key handling
