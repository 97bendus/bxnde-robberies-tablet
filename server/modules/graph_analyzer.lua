local MAX_DEPTH    = 32
local MAX_ITEMS    = 32
local MAX_SECURITY = 16
local MAX_POLICE   = 255
local MAX_REWARD   = 2000000000
local MAX_TIME     = 86400

local SECURITY_WORDS = { 'laser', 'hack', 'thermite' }

local FIELD_PRIORITY = {
    police = {
        requiredpolice = 1,
        policerequired = 1,
        requiredpolicecount = 1,
        policecountrequired = 1,
        minimumpolice = 1,
        minpolice = 1,
        minpolicecount = 1,
        minimumpolice = 1,
        policeamount = 2,
        policecount = 2,
        police = 3,
        requiredcops = 1,
        requiredcopscount = 1,
        copsrequired = 1,
        copsneeded = 1,
        mincops = 1,
        copscount = 2,
        cops = 3,
    },
    reward = {
        estimatedreward = 1,
        estimatedmoney = 1,
        rewardamount = 1,
        moneyreward = 1,
        cashreward = 1,
        robberyreward = 1,
        totalreward = 1,
        payout = 2,
        minreward = 2,
        maxreward = 2,
        reward = 2,
        money = 3,
        cash = 3,
    },
    estimatedTime = {
        estimatedtime = 1,
        robberytime = 2,
        duration = 2,
        timetocomplete = 2,
        timelimit = 3,
        time = 4,
    }
}

local function normalizeKey(key)
    return tostring(key):lower():gsub('[^%w]', '')
end

local function isSecurityText(text)
    text = tostring(text):lower()
    for i = 1, #SECURITY_WORDS do
        if text:find(SECURITY_WORDS[i], 1, true) then return true end
    end
    return false
end

local function clamp(value, max)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then
        return nil
    end
    return math.max(0, math.min(value, max))
end

local function defaults()
    return {
        items         = {},
        security      = {},
        police        = tonumber(Config.MinimumPoliceDefault) or 0,
        reward        = tonumber(Config.DefaultEstimatedReward) or 0,
        estimatedTime = 0,
        category      = 'general',
    }
end

local function addItem(result, found, name, count)
    if type(name) ~= 'string' or #name > 64 or not name:find('^[%w_%-%.:]+$') then return end

    count = clamp(count or 1, 1000)
    count = count and math.max(1, math.floor(count)) or 1

    local existing = found[name]
    if existing then
        existing.count = math.max(existing.count, count)
    elseif #result.items < MAX_ITEMS then
        existing = { name = name, count = count }
        found[name] = existing
        result.items[#result.items + 1] = existing
    end
end

local function addSecurity(result, found, text)
    text = tostring(text):sub(1, 64)
    if found[text] or #result.security >= MAX_SECURITY then return end

    found[text] = true
    result.security[#result.security + 1] = text
end

local function numberFrom(value)
    if type(value) == 'number' or type(value) == 'string' then
        return tonumber(value)
    end

    if type(value) == 'table' then
        local best
        for _, key in ipairs({ 'value', 'amount', 'total', 'estimated', 'min', 'minimum', 'max', 'maximum' }) do
            local candidate = tonumber(value[key])
            if candidate and (not best or candidate > best) then
                best = candidate
            end
        end
        return best
    end
end

local function setCandidate(candidates, kind, key, value)
    local priority = FIELD_PRIORITY[kind][key]
    if not priority then return end

    local number = numberFrom(value)
    local max = kind == 'police' and MAX_POLICE
        or kind == 'reward' and MAX_REWARD
        or MAX_TIME

    number = clamp(number, max)
    if not number then return end

    local current = candidates[kind]
    if not current or priority < current.priority
        or (priority == current.priority and number > current.value) then
        candidates[kind] = { priority = priority, value = number }
    end
end

local function walk(node, depth, seen, found, result, candidates)
    if type(node) == 'string' then
        local trimmed = node:match('^%s*(.*)') or node
        if trimmed:sub(1, 1) ~= '{' and trimmed:sub(1, 1) ~= '[' then return end
        local decoded = SafeJsonDecode(node)
        if type(decoded) == 'table' then node = decoded else return end
    end
    if type(node) ~= 'table' or seen[node] or depth > MAX_DEPTH then return end
    seen[node] = true

    for key, value in pairs(node) do
        local name = normalizeKey(key)
        local kind = type(value)

        setCandidate(candidates, 'police', name, value)
        setCandidate(candidates, 'reward', name, value)
        setCandidate(candidates, 'estimatedTime', name, value)

        if kind == 'table' then
            if value.item or (value.name and (value.count or value.amount or value.required)) then
                addItem(result, found.items, value.item or value.name, value.count or value.amount or value.required)
            end

            if isSecurityText(name) then
                addSecurity(result, found.security, name)
            end

            walk(value, depth + 1, seen, found, result, candidates)
        elseif kind == 'string' and isSecurityText(value) then
            addSecurity(result, found.security, value)
        end
    end
end

function GraphAnalyzer_Parse(raw, label, robberyId)
    local data, err = SafeJsonDecode(raw)

    if type(data) ~= 'table' then
        Debug('GRAPH', 'Could not read graph of %s: %s', tostring(label), tostring(err))
        Webhook_Send('default', 'wh_event_bad_graph',
            ('Robbery: %s\nError: %s'):format(tostring(label), tostring(err or 'not an object')), 'error')
        return defaults()
    end

    local result = defaults()
    local candidates = {}
    walk(data, 0, {}, { items = {}, security = {} }, result, candidates)

    if candidates.police then result.police = math.floor(candidates.police.value) end
    if candidates.reward then result.reward = math.floor(candidates.reward.value) end
    if candidates.estimatedTime then result.estimatedTime = math.floor(candidates.estimatedTime.value) end

    local graph = type(data.nodeGraph) == 'table' and data.nodeGraph or data
    local nodes = type(graph) == 'table' and graph.nodes or nil
    if type(nodes) == 'table' then
        local graphPolice, graphReward
        for _, node in pairs(nodes) do
            local d = type(node) == 'table' and node.data or nil
            if type(d) == 'table' then
                local condition = tostring(d.conditionType or ''):lower()
                if condition == 'police_count' then
                    local count = tonumber(d.minCount or d.minimum or d.count)
                    if count and count >= 0 and count <= MAX_POLICE then
                        graphPolice = math.floor(count)
                    end
                end

                local action = tostring(d.actionType or ''):lower()
                if action == 'give_money' or action == 'give_item' then
                    local item = tostring(d.item or ''):lower()
                    local amount = tonumber(d.maxAmount or d.amount)
                    local multiplier = tonumber(d.multiplier)
                    if multiplier and multiplier > 0 then
                        local base = tonumber(d.amount) or 1
                        amount = math.max(amount or 0, base * multiplier)
                    end
                    if amount and amount > 0 and amount <= MAX_REWARD
                        and (action == 'give_money' or item == 'black_money' or item == 'money' or item == 'cash') then
                        graphReward = math.max(graphReward or 0, math.floor(amount))
                    end
                end
            end
        end
        if graphPolice ~= nil then result.police = graphPolice end
        if graphReward ~= nil then result.reward = graphReward end
    end

    if type(data.category) == 'string' and data.category ~= '' then
        result.category = data.category:sub(1, 32)
    end

    local overrides = Config.RobberyEstimates or {}
    local override = overrides[tostring(robberyId)] or overrides[tostring(label):lower()] or overrides[tostring(label)]
    if type(override) == 'table' then
        if tonumber(override.police) then
            result.police = math.floor(clamp(override.police, MAX_POLICE) or result.police)
        end
        if tonumber(override.reward) then
            result.reward = math.floor(clamp(override.reward, MAX_REWARD) or result.reward)
        end
        if tonumber(override.estimatedTime) then
            result.estimatedTime = math.floor(clamp(override.estimatedTime, MAX_TIME) or result.estimatedTime)
        end
    end

    return result
end
