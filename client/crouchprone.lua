local isCrouching = false
local walkSet = 'default'

local function loadAnimSet(anim)
    if HasAnimSetLoaded(anim) then return end
    RequestAnimSet(anim)
    while not HasAnimSetLoaded(anim) do
        Wait(10)
    end
end

local function resetAnimSet()
    local ped = PlayerPedId()
    ResetPedMovementClipset(ped, 1.0)
    ResetPedWeaponMovementClipset(ped)
    ResetPedStrafeClipset(ped)
    
    if walkSet ~= 'default' then
        loadAnimSet(walkSet)
        SetPedMovementClipset(ped, walkSet, 1.0)
        RemoveAnimSet(walkSet)
    end
end

RegisterNetEvent('crouchprone:client:SetWalkSet', function(clipset)
    walkSet = clipset
end)

CreateThread(function()
    local sleep, ped
    while true do
        sleep = 1000
        ped = PlayerPedId() -- We get only once per iteration
        DisableControlAction(0, 36, true)

        if not IsPedSittingInAnyVehicle(ped) and not IsPedFalling(ped) and not IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped) and not IsPauseMenuActive() then
            if IsDisabledControlJustReleased(2, 36) then
                sleep = 0
                ClearPedTasks(ped)

                if isCrouching then
                    resetAnimSet()
                    SetPedStealthMovement(ped, false, 'DEFAULT_ACTION')
                else
                    loadAnimSet('move_ped_crouched')
                    SetPedMovementClipset(ped, 'move_ped_crouched', 1.0)
                    SetPedStrafeClipset(ped, 'move_ped_crouched_strafing')
                end

                isCrouching = not isCrouching
            end
        end

        Wait(sleep)
    end
end)
