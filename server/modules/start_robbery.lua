local locks = {}
local busy  = {}

local function reject(src, key, category, title, detail, level)
    NotifyPlayer(src, key, 'error')
    Webhook_Send(category, title, ('%s\n%s'):format(PlayerLabel(src), detail), level or 'error')
    return false
end

local function parseId(value)
    local kind = type(value)

    if kind == 'number' then
        return math.tointeger(value)
    elseif kind == 'string' and #value > 0 and #value <= 64 then
        return value
    end
end

local function lockKey(entry, src, player)
    local mode = Config.CooldownMode

    if mode == 'personal' then
        return ('%s:%s'):format(entry.id, Framework_GetIdentifier(player) or ('src' .. src))
    elseif mode == 'job' then
        return ('%s:%s'):format(entry.id, Framework_GetJob(player) or ('src' .. src))
    end

    return tostring(entry.id)
end

local function run(src, rawId)
    local id = parseId(rawId)
    if id == nil then
        return reject(src, 'error', 'admin', 'wh_event_rejected_id',
            ('Payload type: %s'):format(type(rawId)), 'warning')
    end

    if not IsPlayerValid(src) then
        Debug('START', 'Source %s is not a valid player', src)
        return false
    end

    local entry = Robberies_GetById(id)
    if not entry then
        return reject(src, 'error', 'admin', 'wh_event_rejected_unknown',
            ('Id: `%s`'):format(tostring(id)), 'warning')
    end

    local player = Framework_GetPlayer(src)
    local graph  = entry.graph
    local info   = ('Robbery: %s (ID: %s)'):format(entry.name, tostring(entry.id))

    if not TabletRequirementMet(src) then
        return reject(src, 'error', 'stop', 'wh_event_no_tablet', info)
    end

    if GetResourceState(Config.CreatorResource) ~= 'started' then
        ErrorLog('START', ('%s is not running, nothing can start the robbery'):format(Config.CreatorResource))
        return reject(src, 'error', 'default', 'wh_event_creator_offline', info)
    end

    local remaining = Cooldown_GetRemaining(entry.id, player)
    if remaining == nil then
        return reject(src, 'error', 'default', 'wh_event_cooldown_unreadable', info)
    elseif remaining > 0 then
        return reject(src, 'cooldownActive', 'stop', 'wh_event_cooldown_active',
            ('%s\nRemaining: %s sec'):format(info, remaining))
    end

    if Config.RequirePoliceOnline and graph.police > 0 then
        local online = Permissions_CountPolice()
        if online < graph.police then
            return reject(src, 'notEnoughPolice', 'stop', 'wh_event_police',
                ('%s\nRequired: %s\nOnline: %s'):format(info, graph.police, online))
        end
    end

    if Config.RequireRobberyItems then
        for _, required in ipairs(graph.items or {}) do
            if not Inventory_HasItem(src, required.name, required.count) then
                return reject(src, 'noItems', 'stop', 'wh_event_missing_item',
                    ('%s\nItem: %s x%s'):format(info, required.name, required.count))
            end
        end
    end

    local key = lockKey(entry, src, player)
    local now = os.time()
    if locks[key] and locks[key] > now then
        return reject(src, 'cooldownActive', 'stop', 'wh_event_already_starting', info)
    end
    locks[key] = now + Config.StartLockSeconds

    TriggerEvent(Config.StartEvent, src, entry.id, entry.row)
    --NotifyPlayer(src, 'started', 'success')
    Webhook_Send('start', 'wh_event_started',
        ('%s\n%s\nReward: $%s'):format(PlayerLabel(src), info, graph.reward), 'success')

    return true
end

function StartRobbery_Handle(src, rawId)
    if busy[src] then return false end

    busy[src] = true
    local ok, result = pcall(run, src, rawId)
    busy[src] = nil

    if not ok then
        ErrorLog('START', result)
        return false
    end

    return result
end

AddEventHandler('playerDropped', function()
    busy[source] = nil
end)