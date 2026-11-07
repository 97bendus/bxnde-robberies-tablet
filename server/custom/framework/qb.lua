-- [INFO] QBCore server bridge; inactive unless Config.Framework is 'qb'.
if Config.Framework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

--- Returns the QBCore player object for a given source ID.
--- @param src number
--- @return table|nil
function Framework_GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

--- Returns the player's unique identifier (citizenid).
--- @param player table|nil
--- @return string|nil
function Framework_GetIdentifier(player)
    return player and player.PlayerData and player.PlayerData.citizenid
end

--- Returns the player's current job name.
--- @param player table|nil
--- @return string|nil
function Framework_GetJob(player)
    local data = player and player.PlayerData
    return data and data.job and data.job.name
end

--- Checks whether the player has any of the configured admin permissions.
--- @param player table|nil
--- @return boolean
function Framework_IsAdmin(player)
    local src = player and player.PlayerData and player.PlayerData.source
    if not src then return false end

    for _, group in ipairs(Config.AdminGroups) do
        if QBCore.Functions.HasPermission(src, group) then return true end
    end
    return false
end

if type(Config.TabletItem) == 'string' and Config.TabletItem ~= '' then
    QBCore.Functions.CreateUseableItem(Config.TabletItem, function(source)
        TriggerClientEvent('bxnde-robberies-tablet:opentablet', source)
    end)
end