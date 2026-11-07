-- [INFO] ESX server bridge; inactive unless Config.Framework is 'esx'.
if Config.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

--- Returns the ESX player object for a given source ID.
--- @param src number
--- @return table|nil
function Framework_GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

--- Returns the player's unique identifier.
--- @param player table|nil
--- @return string|nil
function Framework_GetIdentifier(player)
    return player and player.identifier
end

--- Returns the player's current job name.
--- @param player table|nil
--- @return string|nil
function Framework_GetJob(player)
    return player and player.job and player.job.name
end

--- Checks whether the player belongs to an admin group.
--- @param player table|nil
--- @return boolean
function Framework_IsAdmin(player)
    if not player or not player.getGroup then return false end

    local group = player.getGroup()
    for _, allowed in ipairs(Config.AdminGroups) do
        if group == allowed then return true end
    end
    return false
end

if type(Config.TabletItem) == 'string' and Config.TabletItem ~= '' then
    ESX.RegisterUsableItem(Config.TabletItem, function(source)
        TriggerClientEvent('bxnde-robberies-tablet:opentablet', source)
    end)
end