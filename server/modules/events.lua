local EVENT = 'bxnde-robberies-tablet:'

RegisterNetEvent(EVENT .. 'requestlist', function()
    local src = tonumber(source)
    if not src or RateLimit_Hit(src, 'list', Config.RateLimit.list) then return end
    if not IsPlayerValid(src) then return end

    if not TabletRequirementMet(src) then
        NotifyPlayer(src, 'error')
        Webhook_Send('admin', 'wh_event_list_without_tablet', PlayerLabel(src), 'warning')
        return
    end

    local cooldowns = Cooldown_GetAll(Framework_GetPlayer(src))
    local output = Tablet_GetSortedEntries(cooldowns)

    TriggerClientEvent(EVENT .. 'receiveList', src, output)
end)

RegisterNetEvent(EVENT .. 'startrobbery', function(robberyId)
    local src = tonumber(source)
    if not src or RateLimit_Hit(src, 'start', Config.RateLimit.start) then return end

    StartRobbery_Handle(src, robberyId)
end)