local policeJobs = {}
for _, job in ipairs(Config.PoliceJobs) do
    policeJobs[job] = true
end

local warned = false

function Permissions_CountPolice()
    if Config.Framework == 'standalone' then
        if not warned then
            warned = true
            ErrorLog('PERMISSIONS', 'Cannot count police without a framework')
        end
        return 0
    end

    local count = 0
    for _, id in ipairs(GetPlayers()) do
        local job = Framework_GetJob(Framework_GetPlayer(tonumber(id)))
        if job and policeJobs[job] then
            count = count + 1
        end
    end

    return count
end