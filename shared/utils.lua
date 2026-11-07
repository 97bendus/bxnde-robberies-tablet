function SafeJsonDecode(value)
    if type(value) ~= 'string' then return nil, 'not a string' end

    local ok, decoded = pcall(json.decode, value)
    if not ok then return nil, decoded end

    return decoded
end
function SafeIdentifier(name)
    return type(name) == 'string' and name:find('^[%w_]+$') ~= nil
end

local function loadLocale(code)
    if type(code) ~= 'string' or not code:find('^[%a_%-]+$') then return {} end

    local raw = LoadResourceFile(Config.ResourceName, ('locales/%s.json'):format(code))
    return raw and SafeJsonDecode(raw) or {}
end

local cached, cachedFor

function GetLocale()
    if cached and cachedFor == Config.Locale then return cached end

    local merged = loadLocale('en')
    for key, value in pairs(loadLocale(Config.Locale)) do
        merged[key] = value
    end

    cached, cachedFor = merged, Config.Locale
    return merged
end

function Translate(key)
    return GetLocale()[key] or key
end

function oneOf(name, allowed, fallback)
    local value = Config[name]
    for i = 1, #allowed do
        if allowed[i] == value then return value end
    end

    print(('^3[%s] Config.%s has an invalid value (%s), using "%s"^7'):format(
        Config.ResourceName, name, tostring(value), fallback))
    return fallback
end

function detect(candidates, fallback)
    for i = 1, #candidates do
        if GetResourceState(candidates[i][1]) == 'started' then
            return candidates[i][2]
        end
    end
    return fallback
end