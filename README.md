# bxnde-robberies-tablet

Robbery tablet for FiveM. It reads robberies from the Quasar Robberies Creator database, displays them in a NUI tablet, and requests a robbery start through a custom trigger node that you add to `qs-robberies-creator` using the instructions below.

> **Important:** the Creator custom-node API expects one definition table with both `kind` and `nodeType`. Do not use the older `RegisterCustomNode('tablet_start', {...})` signature; it causes `RegisterCustomNode: def requires kind and nodeType`.

## Contents

1. [Install](#1-install)
2. [Creator custom node](#2-creator-custom-node)
3. [Config](#3-config)
4. [Server-side checks](#4-server-side-checks)
5. [Database](#5-database)
6. [Troubleshooting](#6-troubleshooting)
7. [Commands, events and custom nodes](#7-commands-events-and-custom-nodes)
8. [UI](#8-ui)

## 1. Install

1. Put the complete `bxnde-robberies-tablet` folder into `resources/[local]/`.
2. Ensure dependencies start before the tablet:
   ```cfg
   ensure oxmysql
   ensure ox_lib
   ensure qs-robberies-creator
   ensure bxnde-robberies-tablet
   ```
3. Review `config/main.lua`.
4. Follow [Creator custom node](#2-creator-custom-node) and add the custom node directly to your installed Creator resource.
5. Restart the resources and open the tablet using `/robberies` (or configure `Config.Command` / `Config.OpenKey`).

**Optional tablet item.** Configure `Config.TabletItem` and create the item in your inventory. To open it from an inventory item callback, trigger `bxnde-robberies-tablet:opentablet` on the client.

### ESX inventory SQL

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`, `description`)
VALUES ('robbery_tablet', 'Robbery Tablet', 1000, 1, 1,
        'A specialized tablet used to view, manage and launch available robberies');
```

### ox_inventory item

Add to `ox_inventory/data/items.lua`:

```lua
['robbery_tablet'] = {
    label = 'Robbery tablet',
    weight = 100,
    stack = false,
    close = true,
    description = 'A specialized tablet used to view, manage and launch available robberies',
},
```

For QB or QS inventory, add an equivalent item definition to the item file used by your installed inventory.

## 2. Creator custom node

The tablet emits `Config.StartEvent` on the server with `(source, robberyId, row)`. Add a custom trigger node inside your **installed** `qs-robberies-creator` resource; this integration is intentionally documented here rather than shipped as a separate folder.

1. Back up `qs-robberies-creator` before editing it.
2. Create `qs-robberies-creator/server/custom/nodes/tablet_start.lua` (or use the custom-node directory configured by your installed Creator version).
3. Paste the complete code below into that file.
4. Confirm the Creator loads custom node files **after** `RegisterCustomNode` is defined. If it does not automatically load `server/custom/nodes/*.lua`, add this file to the Creator's server script list in its `fxmanifest.lua`, using a path relative to the Creator resource.
5. Restart `qs-robberies-creator`, then restart `bxnde-robberies-tablet`.
6. In Robberies Creator, add **Tablet Start** as the trigger/start node for every robbery that should be launchable from the tablet. Save the robbery and make sure its ID or name matches the robbery entry read by the tablet.

```lua
-- qs-robberies-creator/server/custom/nodes/tablet_start.lua
-- Register this custom trigger in the Creator resource itself.

if type(RegisterCustomNode) ~= 'function' then
    print('[bxnde-robberies-tablet] RegisterCustomNode is unavailable; check Creator load order/version.')
    return
end

local starters = {}

local function addStarterKey(key, start)
    if key == nil then return end
    key = tostring(key)
    if key == '' then return end
    starters[key] = start
    starters[key:lower()] = start
end

local function findStarter(robberyId, robberyData)
    local candidates = {
        robberyId,
        type(robberyData) == 'table' and robberyData.id or nil,
        type(robberyData) == 'table' and robberyData.name or nil,
        type(robberyData) == 'table' and robberyData.robberyId or nil,
    }

    for _, candidate in ipairs(candidates) do
        if candidate ~= nil then
            local key = tostring(candidate)
            if starters[key] then return starters[key] end
            if starters[key:lower()] then return starters[key:lower()] end
        end
    end
end

RegisterCustomNode({
    kind = 'tablet_start',
    nodeType = 'trigger',
    label = 'Tablet Start',
    description = 'Starts this robbery from bxnde-robberies-tablet.',
    category = 'triggers',
    icon = 'IoTabletPortrait',
    fields = {
        { key = 'tag', type = 'text', label = 'Tablet robbery ID/name (optional)', description = 'Optional ID/name matching the tablet entry.' },
    },
    setup = function(robbery, node, start)
        local tag = node and node.data and node.data.tag
        addStarterKey(tag, start)
        if robbery then
            addStarterKey(robbery.id, start)
            addStarterKey(robbery.name, start)
        end
    end,
})

AddEventHandler('bxnde-robberies-tablet:customstart', function(source, robberyId, robberyData)
    local start = findStarter(robberyId, robberyData)
    if not start then
        print(('[bxnde-robberies-tablet] No Tablet Start trigger registered for robbery ID/name: %s'):format(tostring(robberyId)))
        return
    end

    local playerId = tonumber(source)
    if not playerId or not GetPlayerName(playerId) then return end
    start(playerId)
end)
```

The `RegisterCustomNode` API used here expects one definition table containing both `kind` and `nodeType`; do not use the older positional signature. `kind` must be unique and `nodeType` must be `trigger` for this node. The `setup(robbery, node, start)` callback stores the Creator's `start` callback for each robbery; the event handler resolves the matching robbery and calls `start(playerId)`.

**Matching IDs:** the node automatically registers the Creator robbery ID and name. The optional **Tablet robbery ID/name** field can add another match key. If the console reports that no trigger is registered, compare the ID/name stored in `qs_robberies` with the Creator robbery ID/name and the optional tag.

**Version note:** Quasar's custom-node loader and API can differ between releases. If `RegisterCustomNode` is unavailable, adjust the file's load location/order according to the installed Creator version's own documentation rather than placing this file in the tablet resource.

## 3. Config

Everything is configured in `config/main.lua`.

| Option | Description |
| --- | --- |
| `Config.Locale` | `en`, `hu` or `es`; additional locale JSON files can be added under `locales/`. |
| `Config.Framework`, `Config.Inventory`, `Config.Notify` | `auto` detects the running resources. |
| `Config.TabletItem` | Required item name, or `false` to disable the item requirement. |
| `Config.CooldownMode` | `global`, `personal` or `job`. |
| `Config.PoliceJobs` | Job names counted as police. |
| `Config.RateLimit` | Minimum time between requests, in milliseconds. |
| `Config.StartLockSeconds` | Prevents the same robbery from starting repeatedly within this period. |
| `Config.CacheSeconds` | Robbery-list cache duration. |
| `Config.Images`, `Config.Descriptions` | Card images and descriptions keyed by robbery ID or name. |
| `Config.StartEvent` | Server event emitted after the tablet's checks pass. Default: `bxnde-robberies-tablet:customstart`. |

Discord logging is configured in `server/custom/webhooks/main.lua`.

## 4. Server-side checks

The server does not trust client-provided robbery data. List and start requests are checked for:

- rate limit per player and event (`Config.RateLimit`);
- online, spawned, alive player and framework identity;
- tablet item, when required;
- robbery ID resolved from the server-side list rather than interpolated into SQL;
- cooldown, according to `Config.CooldownMode`;
- police online, when `Config.RequirePoliceOnline` is enabled;
- required items extracted from the robbery graph;
- a start lock (`Config.StartLockSeconds`).

Missing bridges and database errors reject a request. With `Config.Inventory = 'none'`, item requirements cannot be verified and fail closed.

Rejected and suspicious requests can be sent to Discord webhooks configured in `server/custom/webhooks/main.lua`.

## 5. Database

Default robbery table: `qs_robberies`, columns `id`, `name`, `data`.

Default cooldown table: `qs_robbery_cooldowns`, columns `robbery_id`, `identifier`, `job`, `expires_at` (Unix seconds; milliseconds are converted).

- Table and robbery column settings: `config/main.lua`.
- Cooldown columns: `server/modules/cooldown.lua`.
- Robbery data is cached for `Config.CacheSeconds`.

## 6. Troubleshooting

Enable `Config.Debug = true`. Logs are prefixed with `[bxnde-robberies-tablet][MODULE]`.

| Problem | Check |
| --- | --- |
| Tablet does not open | F8 console, command/key settings, and `web/build/index.html`. |
| Robbery list is empty | oxmysql, table name, and configured column names. |
| Robberies always look available | Cooldown table and `expires_at` format. |
| Items are not recognised | `Config.Inventory` and the actual inventory item names. |
| `RegisterCustomNode: def requires kind and nodeType` | Use the definition-table code in the README and ensure the file is loaded by the Creator after `RegisterCustomNode` is defined. |
| Robbery does not start | Check that **Tablet Start** is saved as a trigger, Creator has loaded `server/custom/nodes/tablet_start.lua`, and the Creator robbery ID/name matches the tablet row. Check server console for “No Tablet Start trigger is registered”. |
| No notifications | `Config.Notify` and the matching notification resource. |

## 7. Commands, events and custom nodes

### Commands

The tablet command is configurable through `Config.Command` (default `/robberies`). The Quasar Robberies Creator also registers its own staff commands; their exact names and permissions are controlled by the installed Creator version and its `/robberiesconfig` settings.

### Events

**Open the tablet**

```lua
-- client-side
TriggerEvent('bxnde-robberies-tablet:opentablet')
```

**Tablet-to-Creator start request**

```lua
-- server-side event; emitted after tablet-side server validation
-- Arguments: source, robberyId, row
AddEventHandler('bxnde-robberies-tablet:customstart', function(source, robberyId, row)
    -- The custom node added to `qs-robberies-creator` resolves the matching trigger and calls `start(source)`.
end)
```

**Creator notifications** (for resources using the Creator notification event; confirm support in your installed Creator version):

```lua
TriggerClientEvent('qs-robberies:notify', source, 'The vault is open', 'success', 5000)
-- type: info, success, warning, error; duration is milliseconds
```

### Custom nodes

The Creator supports custom actions, conditions and triggers registered in Lua under `server/custom/nodes/`. Its documented definition format is a single table:

```lua
RegisterCustomNode({
    kind = 'example_action',
    nodeType = 'action', -- 'action', 'condition' or 'trigger'
    label = 'Example Action',
    category = 'rewards',
    fields = {},
    handler = function(context, node)
        return true
    end,
})
```

For trigger nodes, use `setup(robbery, node, start)` and call `start(playerId)` to begin the robbery for that player. See the complete `tablet_start.lua` example in [Creator custom node](#2-creator-custom-node). The Creator's node runtime and exported helper names can vary by version; use the installed Creator's own documentation for additional event/export details.

## 8. UI

`web/build/index.html` is the file loaded by FiveM. The source files are under `web/src`. If you change the source UI, rebuild from `web/` with the package scripts and ensure the built file is included in the resource.

## v7 Discord logging and Creator setup

- Wheel scrolling uses eased movement in the robbery list and main view; dragging the scrollbar remains native.
- Scrollbar hover effects transition more gradually and use the active theme colors.
- The countdown robbery information panel is positioned higher to keep more of the gameplay visible.
- Discord Components V2 logs use a dark navy `#000B4A` container, category-specific headings, separators, player/robbery/reward details, and a timestamp footer inspired by the project's ticket bot.

- Each available player identifier is shown in its own copyable code block; Discord users are mentioned directly when a Discord identifier is available. The log includes the FiveM name, IC name, server ID, framework ID, job and available platform identifiers. Player tokens are not collected or logged.
- Creator integration source is documented in this README and is not included as an `integration/` folder in the resource ZIP.
