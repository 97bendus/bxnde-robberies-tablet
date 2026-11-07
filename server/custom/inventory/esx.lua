-- [INFO] ESX inventory bridge, uses the ESX player inventory methods.
-- Inventory_HasItem lives in modules/bridge.lua and is shared by every inventory.
if Config.Inventory ~= 'esx' then return end

--- Returns the amount of a specific item in the player's inventory.
--- @param src number
--- @param item string
--- @return number
function Inventory_GetItemCount(src, item)
    local player = Framework_GetPlayer(src)
    if not player then return 0 end

    local entry = player.getInventoryItem(item)
    return entry and entry.count or 0
end

--- Adds an item to the player's inventory.
--- @param src number
--- @param item string
--- @param count number|nil  Defaults to 1.
function Inventory_AddItem(src, item, count)
    local player = Framework_GetPlayer(src)
    if not player then return end
    return player.addInventoryItem(item, count or 1)
end

--- Removes an item from the player's inventory.
--- @param src number
--- @param item string
--- @param count number|nil  Defaults to 1.
function Inventory_RemoveItem(src, item, count)
    local player = Framework_GetPlayer(src)
    if not player then return end
    return player.removeInventoryItem(item, count or 1)
end