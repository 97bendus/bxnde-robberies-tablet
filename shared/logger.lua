local function prefix(module)
    return ('[%s][%s]'):format(Config.ResourceName, module or 'CORE')
end

function Debug(module, message, ...)
    if not Config.Debug then return end

    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, message, ...)
        message = ok and formatted or message
    end

    print(('%s %s'):format(prefix(module), message))
end
function ErrorLog(module, message)
    print(('^1%s[ERROR]^7 %s'):format(prefix(module), tostring(message)))
end