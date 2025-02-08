local QBCore = exports['qb-core']:GetCoreObject()
local isLoggedIn = LocalPlayer.state.isLoggedIn
local checkUser = true
local prevPos, time = nil, nil
local timeMinutes = {
    ['900'] = 'minutes',
    ['600'] = 'minutes',
    ['300'] = 'minutes',
    ['150'] = 'minutes',
    ['60'] = 'minutes',
    ['30'] = 'seconds',
    ['20'] = 'seconds',
    ['10'] = 'seconds',
}

local function updatePermissionLevel()
    QBCore.Functions.TriggerCallback('qb-afkkick:server:GetPermissions', function(userGroups)
        for k in pairs(userGroups) do
            if Config.AFK.ignoredGroups[k] then
                checkUser = false
                break
            end
            checkUser = true
        end
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    updatePermissionLevel()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnPermissionUpdate', function()
    updatePermissionLevel()
end)

CreateThread(function()
    local sleep = 10000 -- Dynamic sleep
    while true do
        Wait(sleep)

        local ped = PlayerPedId()
        if isLoggedIn or Config.AFK.kickInCharMenu then
            if checkUser then
                local currPos = GetEntityCoords(ped, true)

                -- We check the distance, not the equality of coordinates
                if prevPos and #(currPos - prevPos) < 0.5 then 
                    if time and time > 0 then
                        local _type = timeMinutes[tostring(time)]
                        if _type then
                            local timeText = (_type == 'minutes') and (math.ceil(time / 60) .. Lang:t('afk.time_minutes')) or (time .. Lang:t('afk.time_seconds'))
                            QBCore.Functions.Notify(Lang:t('afk.will_kick') .. timeText, 'error', 10000)
                        end
                        time = time - 10
                    else
                        TriggerServerEvent('KickForAFK')
                    end
                    sleep = 10000 -- AFK continues, we leave a check every 10 seconds
                else
                    time = Config.AFK.secondsUntilKick
                    sleep = 30000 -- If the player is moving, we check less often (once every 30 seconds)
                end

                prevPos = currPos
            end
        end
    end
end)
