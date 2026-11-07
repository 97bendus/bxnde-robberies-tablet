-- [INFO] ESX notification bridge; inactive unless Config.Notify is 'esx'.
if Config.Notify ~= 'esx' then return end

function Notify(msg)
    TriggerEvent('esx:showNotification', msg)
end