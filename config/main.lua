-- [INFO] Central configuration for bxnde-robberies-tablet
Config = Config or {}

-- [CORE] Core options
Config.Locale       = 'en' -- [EDIT] Language: 'en' (English), 'hu' (Magyar), 'es' (Español). Add more files in /locales
Config.Debug        = true -- [EDIT] Verbose module logging
Config.ResourceName = GetCurrentResourceName()
Config.servername   = 'BXNDE' -- [EDIT] Shown as the big watermark (top right) and in the kicker
Config.serverlogo   = 'https://cdn.starlinerp.hu/logo.png' -- [EDIT] Logo URL shown next to the title (top left)
Config.TabletItem   = 'robbery_tablet' -- [EDIT] Inventory item name; set false to not require an item
Config.Command      = 'robberies' -- [EDIT] Chat command
Config.OpenKey      = nil -- [ADV] Optional key mapping, e.g. 'F7'; nil disables it
Config.AdminGroups  = { 'admin', 'superadmin', 'god' }

-- [AUTO] Framework detection. Explicit value wins; 'auto' detects running resources.
Config.Framework = 'auto' -- [EDIT] 'auto', 'esx', 'qb', 'qbox', 'standalone'
if Config.Framework == 'auto' then
    Config.Framework = detect({
        { 'qbx_core', 'qbox' },
        { 'qb-core', 'qb' },
        { 'es_extended', 'esx' },
    }, 'standalone')
end
Config.Framework = oneOf('Framework', { 'esx', 'qb', 'qbox', 'standalone' }, 'standalone')

-- [AUTO] Inventory detection. Explicit value wins; 'auto' detects running resources.
Config.Inventory = 'auto' -- [EDIT] 'auto', 'ox', 'qs', 'qb', 'esx', 'none'
if Config.Inventory == 'auto' then
    local fallback = ({ esx = 'esx', qb = 'qb' })[Config.Framework] or 'none'
    Config.Inventory = detect({
        { 'ox_inventory', 'ox' },
        { 'qs-inventory', 'qs' },
        { 'qb-inventory', 'qb' },
        { 'esx_inventory', 'esx' },
    }, fallback)
end
Config.Inventory = oneOf('Inventory', { 'ox', 'qs', 'qb', 'esx', 'none' }, 'none')

-- [AUTO] Notification provider. Explicit value wins; 'auto' detects running resources.
Config.Notify = 'auto' -- [EDIT] 'auto', 'qs', 'ox', 'qb', 'esx', 'native'
if Config.Notify == 'auto' then
    Config.Notify = detect({
        { 'qs-interface', 'qs' },
        { 'ox_lib', 'ox' },
        { 'qb-core', 'qb' },
        { 'es_extended', 'esx' },
    }, 'native')
end
Config.Notify = oneOf('Notify', { 'qs', 'ox', 'qb', 'esx', 'native' }, 'native')

-- [AUTO] HUD script. It is hidden while the start countdown runs and comes back afterwards.
-- The minimap and the native HUD are always hidden, this only controls your HUD script.
-- Explicit value wins; 'auto' detects running resources.
Config.Hud = 'auto' -- [EDIT] 'auto', 'qs-interface', '17mov_Hud', 'codem-supreme-hud', 'esx_hud', 'jg-hud', 'none'
if Config.Hud == 'auto' then
    Config.Hud = detect({
        { 'qs-interface', 'qs-interface' },
        { '17mov_Hud', '17mov_Hud' },
        { 'codem-supreme-hud', 'codem-supreme-hud' },
        { 'esx_hud', 'esx_hud' },
        { 'jg-hud', 'jg-hud' },
    }, 'none')
end
Config.Hud = oneOf('Hud', { 'qs-interface', '17mov_Hud', 'codem-supreme-hud', 'esx_hud', 'jg-hud', 'none' }, 'none')

-- [EDIT] Robbery list and cooldown behavior
Config.SortMode             = 'name' -- 'name', 'reward', 'police'
Config.PoliceJobs           = { 'police', 'sheriff', 'bcso', 'sasp' }
Config.MinimumPoliceDefault = 0
Config.CooldownMode         = 'global' -- 'global', 'personal', 'job'
Config.RobberyTable         = 'qs_robberies'
Config.CooldownTable        = 'qs_robbery_cooldowns'

-- [INFO] Database schema assumptions are documented in README.md.
Config.Database = {
    RobberiesIdColumn   = 'id',
    RobberiesNameColumn = 'name',
    RobberiesDataColumn = 'data',
}

-- [ADV] Robberies Creator integration
Config.CreatorResource = 'qs-robberies-creator'
Config.StartEvent      = 'bxnde-robberies-tablet:customstart' -- fired on the server with (source, robberyId, row)

-- [EDIT] Rewards are estimates only; actual robbery script controls payout.
Config.DefaultEstimatedReward = 0
Config.RobberyEstimates = {
    -- ['Bank robbery'] = { police = 4, reward = 25000, estimatedTime = 600 },
    -- ['Store robbery'] = { police = 2, reward = 10000, estimatedTime = 300 },
}
Config.RequireTabletItem      = true -- only applies when Config.TabletItem is set
Config.RequireRobberyItems   = false -- set true to enforce graph item requirements
Config.RequirePoliceOnline    = false

-- [ADV] Server side protection. Rate limits are in milliseconds.
Config.RateLimit        = { list = 1000, start = 2500 }
Config.StartLockSeconds = 15 -- the same robbery can't be started again for this long
Config.CacheSeconds     = 30 -- how long the robbery list is cached before it is read from the database again

Config.SortMode     = oneOf('SortMode', { 'name', 'reward', 'police' }, 'name')
Config.CooldownMode = oneOf('CooldownMode', { 'global', 'personal', 'job' }, 'global')

-- [EDIT] Card images for the   tablet. Key = robbery name or robbery id (case-insensitive).
-- Value = file inside web/build/images/ (e.g. 'images/fleeca.png') or a full https:// URL.
-- Robberies without an entry fall back to Config.CategoryImages, then to a generated placeholder.
Config.Images = {
    ['Store Robbery']           = 'images/boosting_sp.jpg',
    ['Paleto Bank Robbery']     = 'images/paleto.png',
    ['Pacific Bank Robbery']    = 'images/pacific.png',
    ['Vangelico Robbery']       = 'images/artasylum.png',
    ['Fleeca Robbery']          = 'images/fleeca.png',
    ['ATM Robbery']             = 'images/cashexchange.png',
    ['Humane Labs Robbery']     = 'images/cargo2.png',
    ['Government Robbery']      = 'images/bobcat.png',
    ['Beach Robbery']           = 'images/cargo.png',
}

Config.CategoryImages = {
    -- bank = 'images/bank.png',
}

-- [EDIT] Optional card descriptions (same keys as Config.Images).
Config.Descriptions = {
    -- ['fleeca bank'] = 'Robbery of a small bank branch using a drill and a laptop.',
}

-- [EDIT] Tablet scene: prop in hand + typing animation + camera in front of the player.
-- The player is shown on the left side of the screen, the UI on the right.
Config.Scene = {
    Enabled   = true,
    Freeze    = true,  -- freeze the player in place while the tablet is open (stable framing)
    HideRadar = true,  -- hide the minimap during the scene
    Prop      = 'prop_cs_tablet',
    Bone      = 60309, -- right hand (PH_R_Hand)
    Offset    = vector3(0.03, 0.002, 0.0),
    Rotation  = vector3(10.0, 160.0, 0.0),
    Dict      = 'amb@code_human_in_bus_passenger_idles@female@tablet@base',
    Anim      = 'base',
    PropDelay = 450,   -- ms until the tablet appears in the hand (after the anim starts)

    Camera = {
        Distance    = 2.1,   -- meters in front of the player
        Height      = 0.45,  -- camera height above the player's origin
        LookHeight  = 0.35,  -- height of the point the camera looks at
        Side        = 0.8,   -- shifts the player to the left of the screen (higher = more left)
        Fov         = 42.0,
        InterpIn    = 1600,  -- ms, turn-around when opening (UI appears at ~55%)
        InterpOut   = 1000,  -- ms, return when closing
        Sway        = 0.012, -- subtle breathing camera movement in meters; 0/false disables
        Dof         = true,  -- depth of field: blurred background
        DofFar      = 3.0,
        DofStrength = 0.9,
    },

    -- The cinematic countdown after pressing "Start". Every effect can be switched off.
    Cinematic = {
        Steps      = 5,     -- how many numbers the countdown has (5 -> 5, 4, 3, 2, 1)
        StepMs     = 1000,  -- how long one number lasts in ms; raise it for a slower countdown (1400 = 7 s)
        Grade      = true,  -- film color grading; turns red for the last 3 seconds
        SlowMo     = true,  -- slow motion during the last 3 seconds
        SlowMoScale = 0.35, -- game speed during slow motion (1.0 = normal)
        Dof        = true,  -- sharp character, blurred background
        Dutch      = true,  -- slightly tilted camera in the last shots
        Animations = true,  -- the character gets ready: knuckles, watch, tie, mask
        BeatPunch  = true,  -- small camera zoom punch on every heartbeat
        Impact     = true,  -- short camera shake when the robbery starts
    },
}