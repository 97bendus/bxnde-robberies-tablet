-- [INFO] qs interface bridge; inactive unless Config.Notify is 'qs'.
if Config.Notify ~= 'qs' then return end

local ICONS = {
    info = 'fas fa-circle-info',
    error = 'fas fa-circle-xmark',
    warning = 'fas fa-triangle-exclamation',
    success = 'fas fa-circle-check',
}

function Notify(msg, title, kind)
    kind = ICONS[kind] and kind or 'info'
    exports['qs-interface']:AddNotify(
        tostring(msg or ''),
        tostring(title or Translate('notifyTitle')),
        5000,
        ICONS[kind]
    )
end