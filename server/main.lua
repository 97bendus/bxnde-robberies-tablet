local MODULES = {
    'modules/bridge.lua',
    'modules/ratelimit.lua',
    'modules/discord.lua',
    'modules/graph_analyzer.lua',
    'modules/robberies.lua',
    'modules/cooldown.lua',
    'modules/permissions.lua',
    'modules/start_robbery.lua',
    'modules/list.lua',
    'modules/events.lua',
    'modules/startup.lua'
}

local resource = GetCurrentResourceName()

for _, path in ipairs(MODULES) do
    local file = 'server/' .. path
    local source = LoadResourceFile(resource, file)
    if not source then
        error(('[%s] Failed to load server module: %s'):format(resource, file))
    end

    local chunk, compileError = load(source, ('@@%s/%s'):format(resource, file), 't')
    if not chunk then
        error(('[%s] Failed to compile server module %s: %s'):format(resource, file, compileError))
    end

    local ok, runtimeError = pcall(chunk)
    if not ok then
        error(('[%s] Failed to initialize server module %s: %s'):format(resource, file, runtimeError))
    end
end