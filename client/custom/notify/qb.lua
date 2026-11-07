-- [INFO] qb notification bridge; inactive unless Config.Notify is 'qb'.
if Config.Notify ~= 'qb' then return end

local TYPES = {
    info    = 'primary',
    error   = 'error',
    warning = 'warning',
    success = 'success',
}

function Notify(msg, _, kind)
    TriggerEvent('QBCore:Notify', msg, TYPES[kind] or TYPES.info)
end