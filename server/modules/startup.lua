local VERSION_URL = 'https://raw.githubusercontent.com/97bendus/version-checks/refs/heads/main/bxnde-robberies-tablet.json'

local COLOR_RESET  = '^7'
local COLOR_ACCENT = '^5'
local COLOR_OK     = '^2'
local COLOR_WARN   = '^3'
local COLOR_ERROR  = '^1'

local BANNER = {
    '██████╗ ██╗  ██╗███╗   ██╗██████╗ ███████╗',
    '██╔══██╗╚██╗██╔╝████╗  ██║██╔══██╗██╔════╝',
    '██████╔╝ ╚███╔╝ ██╔██╗ ██║██║  ██║█████╗  ',
    '██╔══██╗ ██╔██╗ ██║╚██╗██║██║  ██║██╔══╝  ',
    '██████╔╝██╔╝ ██╗██║ ╚████║██████╔╝███████╗',
    '╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝',
}

local function say(color, text)
    print(color .. text .. COLOR_RESET)
end

local function parseVersion(version)
    local parts = {}

    for number in tostring(version):gmatch('%d+') do
        parts[#parts + 1] = tonumber(number)
    end

    return parts
end

local function compareVersions(a, b)
    local pa, pb = parseVersion(a), parseVersion(b)

    for i = 1, math.max(#pa, #pb) do
        local x, y = pa[i] or 0, pb[i] or 0

        if x < y then return -1 end
        if x > y then return 1 end
    end

    return 0
end

local function readLatestVersion(body)
    if type(body) ~= 'string' then return nil end

    local decoded = SafeJsonDecode(body)

    if type(decoded) == 'table' and decoded.version then
        return tostring(decoded.version)
    end

    return body:match('%d+%.%d+[%.%d]*')
end

local function checkVersion(current)
    if type(VERSION_URL) ~= 'string' or VERSION_URL == '' then
        say(COLOR_WARN, '[VERSION] Could not check for updates (no version URL configured)')
        return
    end

    PerformHttpRequest(VERSION_URL, function(code, body)
        local latest = code == 200 and readLatestVersion(body)

        if not latest then
            say(COLOR_WARN, ('[VERSION] Could not retrieve version information (HTTP %s)'):format(tostring(code)))
            return
        end

        local result = compareVersions(current, latest)

        if result < 0 then
            say(COLOR_ERROR, ('[VERSION] Update available: %s -> %s'):format(current, latest))
            say(COLOR_ERROR, ('[VERSION] Download: %s'):format(VERSION_URL))
        elseif result > 0 then
            say(COLOR_WARN, ('[VERSION] Running %s, newer than published %s (development build?)'):format(current, latest))
        else
            say(COLOR_OK, ('[VERSION] Up to date (%s)'):format(current))
        end
    end, 'GET')
end

local function printBanner(current)
    print('')

    for _, line in ipairs(BANNER) do
        say(COLOR_ACCENT, line)
    end

    say(COLOR_ACCENT, ('  ROBBERIES TABLET  |  v%s'):format(current))
    print('')

    local function row(label, value)
        say(COLOR_OK, ('  %-11s'):format(label) .. COLOR_RESET .. tostring(value))
    end

    row('Framework', Config.Framework)
    row('Inventory', Config.Inventory)
    row('Notify', Config.Notify)
    row('Locale', Config.Locale)
    row('Cooldown', Config.CooldownMode)
    row('Creator', GetResourceState(Config.CreatorResource) == 'started' and 'running' or 'NOT running')
    row('Webhook', SVConfig.Webhook.Enabled and 'enabled' or 'disabled')

    print('')
end

CreateThread(function()
    Wait(1000)

    local resourceName = GetCurrentResourceName()
    local current = GetResourceMetadata(resourceName, 'version', 0) or '0.0.0'

    printBanner(current)
    checkVersion(current)
end)