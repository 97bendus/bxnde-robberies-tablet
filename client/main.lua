local MODULES = {
    'modules/core.lua',
    'modules/hud.lua',
    'modules/scene/init.lua',
    'modules/scene/animation.lua',
    'modules/scene/prop.lua',
    'modules/scene/camera.lua',
    'modules/scene/cinematic.lua',
    'modules/scene/cleanup.lua',
    'modules/tablet.lua',
    'modules/events.lua',
    'modules/countdown.lua',
    'modules/callbacks.lua'
}

local resource = GetCurrentResourceName()

for _, path in ipairs(MODULES) do
    local source = LoadResourceFile(resource, 'client/' .. path)
    if not source then
        error(('[%s] Failed to load client module: %s'):format(resource, path))
    end

    local chunk, compileError = load(source, ('@@%s/client/%s'):format(resource, path), 't')
    if not chunk then
        error(('[%s] Failed to compile client module %s: %s'):format(resource, path, compileError))
    end

    local ok, runtimeError = pcall(chunk)
    if not ok then
        error(('[%s] Failed to initialize client module %s: %s'):format(resource, path, runtimeError))
    end
end