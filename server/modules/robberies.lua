local RETRY_MS = 5000

local cache = { entries = {}, byId = {}, expires = 0 }

local function columns()
    local cfg = Config.Database or {}
    return cfg.RobberiesIdColumn or 'id', cfg.RobberiesNameColumn or 'name', cfg.RobberiesDataColumn or 'data'
end

local function CategoryLabel(raw)
    local slug = raw:lower():gsub('[^%w]+', '_'):gsub('^_+', ''):gsub('_+$', '')
    local label = GetLocale()['robcat_' .. slug]
    if label then return label end

    return (raw:gsub('[_%-]+', ' '):gsub('(%a)([%w]*)', function(a, b) return a:upper() .. b end)):sub(1, 32)
end

local function fetch()
    if not SafeIdentifier(Config.RobberyTable) then
        ErrorLog('ROBBERIES', 'Config.RobberyTable is not a valid table name')
        return nil
    end

    local ok, rows = pcall(function()
        return MySQL.query.await(('SELECT * FROM `%s`'):format(Config.RobberyTable))
    end)

    if not ok then
        ErrorLog('ROBBERIES', ('Query failed: %s'):format(tostring(rows)))
        Webhook_Send('default', 'wh_event_db_robbery',
            ('Table: `%s`\n%s'):format(Config.RobberyTable, tostring(rows)), 'error')
        return nil
    end

    local idCol, nameCol, dataCol = columns()
    local entries, byId = {}, {}

    for _, row in ipairs(rows or {}) do
        local id = row[idCol]
        if id ~= nil then
            local name = row[nameCol]
            if type(name) ~= 'string' or name == '' then
                name = 'Robbery #' .. tostring(id)
            end

            local graph = GraphAnalyzer_Parse(row[dataCol], name, id)

            local category = row.category
            if type(category) == 'string' and category ~= '' then
                graph.category = CategoryLabel(category)
            end

            local entry = {
                id    = id,
                name  = name,
                graph = graph,
                row   = row,
            }

            entries[#entries + 1] = entry
            byId[tostring(id)] = entry
        end
    end

    return entries, byId
end

local function refresh()
    local now = GetGameTimer()
    if now < cache.expires then return end

    local entries, byId = fetch()

    if entries then
        cache.entries, cache.byId = entries, byId
        cache.expires = now + Config.CacheSeconds * 1000
        Debug('ROBBERIES', 'Loaded %s robberies', #entries)
    else
        cache.expires = now + RETRY_MS
    end
end

function Robberies_GetAll()
    refresh()
    return cache.entries
end

function Robberies_GetById(id)
    refresh()
    return cache.byId[tostring(id)]
end