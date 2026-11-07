-- [EDIT] Discord webhook logging
SVConfig = SVConfig or {}

SVConfig.Webhook = {
    Enabled = true,
    BotName = 'bxnde-robberies-tablet',
    Avatar  = '',

    -- Categorized webhook URLs for different event types.
    Urls = {
        default = '', -- General events and fallback
        start   = '', -- Robbery started events
        stop    = '', -- Rejected or failed start attempts
        admin   = '', -- Exploit attempts and suspicious requests
    },

    -- Accent colors for the Components V2 containers.
    Colors = {
        info    = 3447003,
        success = 5763719,
        error   = 15548997,
        warning = 16776960,
    },
}