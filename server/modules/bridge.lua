Framework_GetPlayer     = Framework_GetPlayer     or function() return nil end
Framework_GetIdentifier = Framework_GetIdentifier or function() return nil end
Framework_GetJob        = Framework_GetJob        or function() return nil end
Framework_IsAdmin       = Framework_IsAdmin       or function() return false end

Inventory_GetItemCount  = Inventory_GetItemCount  or function() return 0 end
Inventory_AddItem       = Inventory_AddItem       or function() end
Inventory_RemoveItem    = Inventory_RemoveItem    or function() end

if Config.Inventory == 'none' then
    print(('^3[%s] No inventory bridge is active, every item requirement will be rejected^7'):format(Config.ResourceName))
end

function Inventory_HasItem(src, item, count)
    return Inventory_GetItemCount(src, item) >= (count or 1)
end

function NotifyPlayer(src, key, kind)
    TriggerClientEvent('bxnde-robberies-tablet:notify', src, Translate(key), kind or 'error')
end

function TabletRequirementMet(src)
    if not Config.RequireTabletItem then return true end
    if type(Config.TabletItem) ~= 'string' or Config.TabletItem == '' then return true end

    return Inventory_HasItem(src, Config.TabletItem, 1)
end

function IsPlayerValid(src)
    if type(src) ~= 'number' or not GetPlayerName(src) then return false end

    local ped = GetPlayerPed(src)
    if ped == 0 or GetEntityHealth(ped) <= 0 then return false end

    if Config.Framework ~= 'standalone' and not Framework_GetPlayer(src) then
        return false
    end

    return true
end