-- [INFO] qs-inventory server bridge.
-- Inventory_HasItem lives in modules/bridge.lua and is shared by every inventory.
if Config.Inventory ~= 'qs' then return end

--- Returns the amount of a specific item in the player's inventory.
--- @param src number
--- @param item string
--- @return number
function Inventory_GetItemCount(src, item)
    return tonumber(exports['qs-inventory']:GetItemTotalAmount(src, item)) or 0
end

--- Adds an item to the player's inventory.
--- @param src number
--- @param item string
--- @param count number|nil  Defaults to 1.
function Inventory_AddItem(src, item, count)
    return exports['qs-inventory']:AddItem(src, item, count or 1)
end

--- Removes an item from the player's inventory.
--- @param src number
--- @param item string
--- @param count number|nil  Defaults to 1.
function Inventory_RemoveItem(src, item, count)
    return exports['qs-inventory']:RemoveItem(src, item, count or 1)
end