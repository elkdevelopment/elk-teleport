ESX = exports["es_extended"]:getSharedObject()
local CurrentAction = nil
local HasAlreadyEnteredMarker = false
local LastZone = nil
local EnteredCoke = false 

AddEventHandler('tp:hasExitedMarker', function(zone)
    if CurrentAction then
        CurrentAction = nil
        lib.hideTextUI()
    end
end)

Citizen.CreateThread(function()
    while true do
        local waitTime = 500
        local coords = GetEntityCoords(PlayerPedId())
        local isInMarker = false
        local currentZone = nil

        for zone, location in pairs(Config.zones) do
            if #(coords - location) < 1.5 then
                isInMarker = true
                currentZone = zone
                waitTime = 0
                break
            end
        end

        if isInMarker then
            if not HasAlreadyEnteredMarker or LastZone ~= currentZone then
                HasAlreadyEnteredMarker = true
                LastZone = currentZone
                CurrentAction = currentZone
            end
            lib.showTextUI('[E] - Teleport', { icon = 'star' })
        elseif HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('tp:hasExitedMarker', LastZone)
        end

        Wait(waitTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if CurrentAction ~= nil and IsControlJustReleased(0, Config.actionKey) then
            local playerPed = PlayerPedId()
            local coords = Config.point[CurrentAction]
            lib.notify({
                title = 'Server Name',
                description = 'Teleporting...',
                type = 'info',
                position = 'top'
            })
            DoScreenFadeOut(1000)
            Wait(1000)

            if CurrentAction == 'CokeEnter' and not EnteredCoke then
                ESX.Game.Teleport(playerPed, coords)
                EnteredCoke = true
                lib.hideTextUI()
            elseif CurrentAction == 'CokeExit' and EnteredCoke then
                ESX.Game.Teleport(playerPed, coords)
                EnteredCoke = false
                lib.hideTextUI()
            elseif CurrentAction == 'CokeEnter' and EnteredCoke then
                lib.notify({
                    title = 'Restricted',
                    description = "You cannot exit through the Coke entrance",
                    type = 'error'
                })
            else
                ESX.Game.Teleport(playerPed, coords)
                lib.hideTextUI()
            end
            Wait(2000)
            DoScreenFadeIn(1000)
            CurrentAction = nil
        end
    end
end)
