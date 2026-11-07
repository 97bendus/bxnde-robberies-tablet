-- [INFO] Native fallback notifier; inactive unless Config.Notify is 'native'.
if Config.Notify ~= 'native' then return end

function Notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(tostring(msg))
    EndTextCommandThefeedPostTicker(false, false)
end