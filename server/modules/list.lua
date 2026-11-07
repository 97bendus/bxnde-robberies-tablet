local function lowerKeys(source)
    local output = {}
    for key, value in pairs(source or {}) do
        output[tostring(key):lower()] = value
    end
    return output
end

local images = lowerKeys(Config.Images)
local descriptions = lowerKeys(Config.Descriptions)

local sorters = {
    name = function(a, b) return a.name:lower() < b.name:lower() end,
    reward = function(a, b) return a.reward > b.reward end,
    police = function(a, b) return a.police < b.police end
}

local function lookup(map, entry)
    return map[entry.name:lower()] or map[tostring(entry.id):lower()]
end

local function resolveImage(path)
    if type(path) ~= 'string' or path == '' then return path end
    if path:match('^https?://') or path:match('^data:') or path:match('^build/') then return path end
    return 'build/' .. path:gsub('^/', '')
end

function Tablet_BuildListEntry(entry, remaining)
    local graph = entry.graph

    return {
        id = entry.id,
        name = entry.name,
        category = graph.category,
        police = graph.police,
        reward = graph.reward,
        items = graph.items,
        security = graph.security,
        estimatedTime = graph.estimatedTime,
        image = resolveImage(lookup(images, entry) or (Config.CategoryImages or {})[graph.category]),
        description = lookup(descriptions, entry),
        cooldown = remaining or 0,
        available = remaining ~= nil and remaining <= 0
    }
end

function Tablet_GetSortedEntries(cooldowns)
    local output = {}

    for _, entry in ipairs(Robberies_GetAll()) do
        local remaining = cooldowns and (cooldowns[tostring(entry.id)] or 0) or nil
        output[#output + 1] = Tablet_BuildListEntry(entry, remaining)
    end

    table.sort(output, sorters[Config.SortMode] or sorters.name)
    return output
end