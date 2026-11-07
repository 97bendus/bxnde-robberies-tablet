local buckets = {}

function RateLimit_Hit(src, key, interval)
    local now = GetGameTimer()
    local bucket = buckets[src]

    if not bucket then
        bucket = {}
        buckets[src] = bucket
    end

    local last = bucket[key]
    if last and now - last < interval then return true end

    bucket[key] = now
    return false
end

AddEventHandler('playerDropped', function()
    buckets[source] = nil
end)