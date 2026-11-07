local function fetch(robberyId)
    if not SafeIdentifier(Config.CooldownTable) then
        ErrorLog('COOLDOWN', 'Config.CooldownTable is not a valid table name')
        return nil
    end

    local query = ('SELECT * FROM `%s`'):format(Config.CooldownTable)
    local params

    if robberyId ~= nil then
        query = query .. ' WHERE `robbery_id` = ?'
        params = { robberyId }
    end

    local ok, rows = pcall(function()
        return MySQL.query.await(query, params)
    end)

    if not ok then
        ErrorLog('COOLDOWN', ('Query failed: %s'):format(tostring(rows)))
        Webhook_Send('default', 'wh_event_db_cooldown',
            ('Table: `%s`\n%s'):format(Config.CooldownTable, tostring(rows)), 'error')
        return nil
    end

    return rows or {}
end

local function context(player)
    return {
        identifier = Framework_GetIdentifier(player),
        job        = Framework_GetJob(player),
    }
end

local function appliesTo(row, ctx)
    local mode = Config.CooldownMode

    if mode == 'personal' then
        return ctx.identifier ~= nil and row.identifier == ctx.identifier
    elseif mode == 'job' then
        return ctx.job ~= nil and row.job == ctx.job
    end

    return true
end

local function expiryOf(row)
    local value = tonumber(row.expires_at or row.expiry or row.cooldown_end)
    if value and value > 1e11 then value = value / 1000 end
    return value
end

local function longestRemaining(rows, ctx, now)
    local remaining = {}

    for _, row in ipairs(rows) do
        local expires = expiryOf(row)
        if expires and expires > now and appliesTo(row, ctx) then
            local key = tostring(row.robbery_id)
            local left = math.ceil(expires - now)
            if left > (remaining[key] or 0) then remaining[key] = left end
        end
    end

    return remaining
end

function Cooldown_GetRemaining(robberyId, player)
    local rows = fetch(robberyId)
    if not rows then return nil end

    return longestRemaining(rows, context(player), os.time())[tostring(robberyId)] or 0
end

function Cooldown_GetAll(player)
    local rows = fetch()
    if not rows then return nil end

    return longestRemaining(rows, context(player), os.time())
end