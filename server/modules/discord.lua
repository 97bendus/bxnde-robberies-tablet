local THROTTLE_MS = 5000
local lastSent = {}

local function tr(key)
    if type(Translate) == 'function' then return Translate(key) end
    return key
end

local EVENT_STYLE = {
    start   = { emoji = '🚨', labelKey = 'wh_category_start', color = 0x000B4A, footerKey = 'wh_footer_system' },
    stop    = { emoji = '⛔', labelKey = 'wh_category_stop', color = 0x000B4A, footerKey = 'wh_footer_security' },
    admin   = { emoji = '🛡️', labelKey = 'wh_category_admin', color = 0x000B4A, footerKey = 'wh_footer_security' },
    default = { emoji = '📋', labelKey = 'wh_category_default', color = 0x000B4A, footerKey = 'wh_footer_general' },
}

local function clip(value, max)
    local text = tostring(value or '')
    return #text > max and (text:sub(1, max - 3) .. '...') or text
end

local function field(labelKey, value)
    if value == nil or tostring(value) == '' then return nil end
    return ('**%s:** `%s`'):format(tr(labelKey), clip(value, 220))
end

local function copyableField(labelKey, value)
    if value == nil or tostring(value) == '' then return nil end
    local safe = tostring(value)
    return ('**%s:**\n```text\n%s\n```'):format(tr(labelKey), clip(safe, 900))
end

local function getPlayerIdentifiers(src)
    local output, discordId = {}, nil
    local prefixLabels = {
        license = 'wh_identifier_license', license2 = 'wh_identifier_license2',
        discord = 'wh_identifier_discord', steam = 'wh_identifier_steam',
        fivem = 'wh_identifier_fivem', xbl = 'wh_identifier_xbl',
        live = 'wh_identifier_live', ip = 'wh_identifier_ip'
    }

    for _, identifier in ipairs(GetPlayerIdentifiers(src) or {}) do
        local prefix, value = identifier:match('^([^:]+):(.+)$')
        local labelKey = prefix and prefixLabels[prefix]
        if prefix == 'discord' and value and value:match('^%d+$') then
            discordId = value
            output[#output + 1] = ('**%s:** <@%s>'):format(tr('wh_identifier_discord'), value)
            output[#output + 1] = copyableField('wh_identifier_discord_id', value)
        elseif labelKey then
            output[#output + 1] = copyableField(labelKey, value)
        elseif identifier ~= '' then
            output[#output + 1] = copyableField('wh_framework_id', identifier)
        end
    end
    return output, discordId
end

local function getCharacterName(player)
    if not player then return nil end

    if Config.Framework == 'esx' then
        if type(player.getName) == 'function' then
            local ok, value = pcall(player.getName)
            if ok and value and value ~= '' then return value end
        end
        if player.name and player.name ~= '' then return player.name end
        local first = player.get and type(player.get) == 'function' and player.get('firstName')
        local last = player.get and type(player.get) == 'function' and player.get('lastName')
        if first or last then return (tostring(first or '') .. ' ' .. tostring(last or '')):gsub('^%s*(.-)%s*$', '%1') end
    else
        local data = player.PlayerData or player
        local charinfo = data.charinfo or data.charInfo or {}
        local first = charinfo.firstname or charinfo.firstName
        local last = charinfo.lastname or charinfo.lastName
        if first or last then return (tostring(first or '') .. ' ' .. tostring(last or '')):gsub('^%s*(.-)%s*$', '%1') end
        if data.name and data.name ~= '' then return data.name end
    end
    return nil
end

function PlayerLabel(src)
    src = tonumber(src)
    if not src then return copyableField('wh_server_id', 'N/A') or '' end

    local lines = {}
    local player = Framework_GetPlayer(src)
    local characterName = getCharacterName(player)
    local discordName = GetPlayerName(src) or tr('wh_unknown')

    lines[#lines + 1] = field('wh_player_name', discordName)
    lines[#lines + 1] = field('wh_character_name', characterName or tr('wh_unknown'))
    lines[#lines + 1] = copyableField('wh_server_id', src)

    local frameworkId = Framework_GetIdentifier(player)
    if frameworkId then lines[#lines + 1] = copyableField('wh_framework_id', frameworkId) end

    local job = Framework_GetJob(player)
    if job then lines[#lines + 1] = field('wh_job', job) end

    local identifiers = getPlayerIdentifiers(src)
    if #identifiers == 0 then lines[#lines + 1] = '> ' .. tr('wh_no_identifiers') end
    for _, identifierLine in ipairs(identifiers) do
        if identifierLine and identifierLine ~= '' then lines[#lines + 1] = identifierLine end
    end

    local filtered = {}
    for _, line in ipairs(lines) do
        if line and line ~= '' then filtered[#filtered + 1] = line end
    end
    return table.concat(filtered, '\n')
end

local function formatDetails(description)
    local lines = {}
    local inCodeBlock = false
    for line in (tostring(description or ''):gsub('\r', '') .. '\n'):gmatch('(.-)\n') do
        line = line:gsub('^%s+', ''):gsub('%s+$', '')
        if line ~= '' then
            if line:match('^```') then
                lines[#lines + 1] = line
                inCodeBlock = not inCodeBlock
            elseif inCodeBlock then
                lines[#lines + 1] = line
            elseif line:sub(1, 2) == '> ' then
                lines[#lines + 1] = clip(line, 900)
            elseif line:match('^Robbery:') then
                local name, id = line:match('^Robbery:%s*(.-)%s*%(%s*ID:%s*(.-)%)$')
                if name then
                    lines[#lines + 1] = ('> **%s:** %s\n> **%s:** `%s`'):format(
                        tr('wh_robbery'), clip(name, 180), tr('wh_robbery_id'), clip(id, 64))
                else
                    lines[#lines + 1] = '> ' .. clip(line, 800)
                end
            elseif line:match('^Reward:') then
                lines[#lines + 1] = ('> **%s:** %s'):format(tr('wh_reward'), clip(line:gsub('^Reward:%s*', '$'), 160))
            elseif line:match('^Required:') then
                lines[#lines + 1] = ('> **%s:** %s'):format(tr('wh_required_police'), clip(line:gsub('^Required:%s*', ''), 80))
            elseif line:match('^Online:') then
                lines[#lines + 1] = ('> **%s:** %s'):format(tr('wh_online_police'), clip(line:gsub('^Online:%s*', ''), 80))
            elseif line:match('^Remaining:') then
                lines[#lines + 1] = ('> **%s:** %s mp'):format(tr('wh_remaining'), clip(line:gsub('^Remaining:%s*', ''), 80))
            elseif line:match('^Item:') then
                lines[#lines + 1] = ('> **%s:** %s'):format(tr('wh_missing_item'), clip(line:gsub('^Item:%s*', ''), 120))
            elseif line:match('^Id:') then
                lines[#lines + 1] = ('> **%s:** `%s`'):format(tr('wh_robbery_id'), clip(line:gsub('^Id:%s*', ''), 80))
            elseif line:match('^Payload type:') then
                lines[#lines + 1] = ('> **%s:** `%s`'):format(tr('wh_payload_type'), clip(line:gsub('^Payload type:%s*', ''), 80))
            elseif line:match('^Table:') then
                lines[#lines + 1] = ('> **%s:** `%s`'):format(tr('wh_table'), clip(line:gsub('^Table:%s*', ''), 100))
            elseif line:match('^Error:') then
                lines[#lines + 1] = ('> **%s:** `%s`'):format(tr('wh_error'), clip(line:gsub('^Error:%s*', ''), 500))
            else
                lines[#lines + 1] = '> ' .. clip(line, 700)
            end
        end
    end
    return table.concat(lines, '\n')
end

function Webhook_Send(category, title, description, level)
    local cfg = SVConfig.Webhook
    if not cfg or not cfg.Enabled then return end

    local url = cfg.Urls and cfg.Urls[category]
    if not url or url == '' then url = cfg.Urls and cfg.Urls.default end
    if not url or url == '' then return end

    local throttleKey = tostring(category) .. tostring(title)
    local now = GetGameTimer()
    if lastSent[throttleKey] and now - lastSent[throttleKey] < THROTTLE_MS then return end
    lastSent[throttleKey] = now

    local style = EVENT_STYLE[category] or EVENT_STYLE.default
    local levelLabel = tr(({ success = 'wh_level_success', warning = 'wh_level_warning', error = 'wh_level_error', info = 'wh_level_info' })[level] or 'wh_level_event')
    local titleText = tr(title)
    local details = formatDetails(description)
    local heading = ('## `%s` %s\n### `🔹` %s'):format(style.emoji, tr(style.labelKey), clip(titleText, 220))
    local body = details ~= '' and details or ('> `ℹ️` ' .. tr('wh_no_details'))
    local footer = ('-# %s • %s • %s'):format(tr(style.footerKey), levelLabel, os.date('%Y.%m.%d. %H:%M:%S'))

    local mentionedUsers = {}
    for userId in body:gmatch('<@(%d+)>') do mentionedUsers[#mentionedUsers + 1] = userId end

    local payload = {
        username = cfg.BotName or 'WESTFORD RP • Robbery System',
        flags = 1 << 15,
        allowed_mentions = { parse = {}, users = mentionedUsers },
        components = {{
            type = 17,
            accent_color = style.color or (cfg.Colors and cfg.Colors[level]) or 0x000B4A,
            components = {
                { type = 10, content = clip(heading, 500) },
                { type = 14, divider = true, spacing = 1 },
                { type = 10, content = clip(body, 3800) },
                { type = 14, divider = true, spacing = 1 },
                { type = 10, content = clip(footer, 300) },
            },
        }},
    }

    if cfg.Avatar and cfg.Avatar ~= '' then payload.avatar_url = cfg.Avatar end
    url = url .. (url:find('?', 1, true) and '&' or '?') .. 'with_components=true'

    PerformHttpRequest(url, function(code)
        if code < 200 or code >= 300 then
            Debug('WEBHOOK', 'Discord answered with %s (%s)', code, category)
        end
    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end
