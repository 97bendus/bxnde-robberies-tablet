-- [INFO] ox notification bridge; inactive unless Config.Notify is 'ox'.
if Config.Notify ~= 'ox' then return end

local TYPES = {
    info    = 'inform',
    error   = 'error',
    warning = 'warning',
    success = 'success',
}

function Notify(msg, title, kind)
    exports.ox_lib:notify({
        title       = title,
        description = msg,
        type        = TYPES[kind] or TYPES.info,
    })
end