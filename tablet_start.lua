if type(RegisterCustomNode) ~= 'function' then
    print('[bxnde-robberies-tablet] RegisterCustomNode is unavailable; check Creator load order/version.')
    return
end

local starters = {}

local function addStarterKey(key, start)
    if key == nil then return end
    key = tostring(key)
    if key == '' then return end
    starters[key] = start
    starters[key:lower()] = start
end

local function findStarter(robberyId, robberyData)
    local candidates = {
        robberyId,
        type(robberyData) == 'table' and robberyData.id or nil,
        type(robberyData) == 'table' and robberyData.name or nil,
        type(robberyData) == 'table' and robberyData.robberyId or nil,
    }

    for _, candidate in ipairs(candidates) do
        if candidate ~= nil then
            local key = tostring(candidate)
            if starters[key] then return starters[key] end
            if starters[key:lower()] then return starters[key:lower()] end
        end
    end
end

RegisterCustomNode({
    kind = 'tablet_start',
    nodeType = 'trigger',
    label = 'Tablet Start',
    description = 'Starts this robbery from bxnde-robberies-tablet.',
    category = 'triggers',
    icon = 'IoTabletPortrait',
    fields = {
        { key = 'tag', type = 'text', label = 'Tablet robbery ID/name (optional)', description = 'Optional ID/name matching the tablet entry.' },
    },
    setup = function(robbery, node, start)
        local tag = node and node.data and node.data.tag
        addStarterKey(tag, start)
        if robbery then
            addStarterKey(robbery.id, start)
            addStarterKey(robbery.name, start)
        end
    end,
})

AddEventHandler('bxnde-robberies-tablet:customstart', function(source, robberyId, robberyData)
    local start = findStarter(robberyId, robberyData)
    if not start then
        print(('[bxnde-robberies-tablet] No Tablet Start trigger registered for robbery ID/name: %s'):format(tostring(robberyId)))
        return
    end

    local playerId = tonumber(source)
    if not playerId or not GetPlayerName(playerId) then return end
    start(playerId)
end)