-- [INFO] qb-inventory bridge, uses the QBCore player item methods.
-- Inventory_HasItem lives in modules/bridge.lua and is shared by every inventory.
if Config.Inventory ~= 'qb' then return end

--- Returns the amount of a specific item in the player's inventory.
--- @param src number
--- @param item string
--- @return number
function Inventory_GetItemCount(src, item)
    local player = Framework_GetPlayer(src)
    if not player or not player.Functions then return 0 end

    -- an item can be spread over several slots
    local total = 0
    for _, stack in pairs(player.Functions.GetItemsByName(item) or {}) do
        total = total + (stack.amount or 0)
    end
    return total
end

--- Adds an item to the player's inventory.
--- @param src number
--- @param item string
--- @param count number|nil  Defaults to 1.
function Inventory_AddItem(src, item, count)
    local player = Framework_GetPlayer(src)
    if not player or not player.Functions then return end
    return player.Functions.AddItem(item, count or 1)
end

--- Removes an item from the player's inventory.
--- @param src number
--- @param item string
--- @param count number|nil  Defaults to 1.
function Inventory_RemoveItem(src, item, count)
    local player = Framework_GetPlayer(src)
    if not player or not player.Functions then return end
    return player.Functions.RemoveItem(item, count or 1)
end