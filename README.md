# bxnde-robberies-tablet – Robbery Tablet for FiveM

A standalone tablet resource that reads robberies from your **Quasar Robberies Creator** database and lets players browse and launch them from a clean NUI interface. Works with ESX, QBCore, QBox, ox_inventory, qs-inventory, and more.

---

## What This Resource Does

- Displays all available robberies from `qs_robberies` in a tablet UI.
- Lets players start a robbery directly from the tablet.
- Supports cooldowns (global, personal, or job-based), police requirements, item requirements, and rate limiting.
- Sends detailed Discord logs for starts, rejects, and suspicious activity.
- Fully server-side validated — the client cannot fake robbery data.

---

## Requirements

Start these **before** the tablet:

```cfg
ensure oxmysql
ensure ox_lib
ensure qs-robberies-creator
ensure bxnde-robberies-tablet
```

---

## Installation

1. Place the `bxnde-robberies-tablet` folder into `resources/[local]/`.
2. Add the `ensure` lines above to your `server.cfg`.
3. Open `config/main.lua` and adjust the settings to your server.
4. Add the **Creator custom node** (see below) to your installed `qs-robberies-creator`.
5. Restart your server or the affected resources.
6. Open the tablet with `/robberies` (or your configured command/key).

---

## Adding the Tablet Item (Optional)

If you want the tablet to require an inventory item (`Config.TabletItem`), add it to your inventory using the correct method below.

### ESX inventory

Run this `SQL` on your database:

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`, `description`)
VALUES ('robbery_tablet', 'Robbery Tablet', 1000, 1, 1,
        'A specialized tablet used to view, manage and launch available robberies');
```

### OX inventory

Add to `ox_inventory/data/items.lua`:

```lua
['robbery_tablet'] = {
    label = 'Robbery Tablet',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A specialized tablet used to view, manage and launch available robberies',
},
```
Place the `robbery_tablet.png` in `ox_inventory/web/images/`.

### QS inventory

Add to `qs-inventory/shared/items.lua`:

```lua
['robbery_tablet'] = {
    ["name"] = "robbery_tablet",
    ["label"] = "Robbery Tablet",
    ["weight"] = 1000,
    ["type"] = "item",
    ["image"] = "robbery_tablet.png",
    ["unique"] = false,
    ["useable"] = true,
    ["shouldClose"] = true,
    ["combinable"] = nil,
    ["description"] = "A specialized tablet used to view, manage and launch available robberies"
},
```
Place the `robbery_tablet.png` in `qs-inventory/web/dist/images/`.

### QB inventory

Add to `qb-core/shared/items.lua`:

```lua
['robbery_tablet'] = {
    ['name'] = 'robbery_tablet',
    ['label'] = 'Robbery Tablet',
    ['weight'] = 1000,
    ['type'] = 'item',
    ['image'] = 'robbery_tablet.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A specialized tablet used to view, manage and launch available robberies'
},
```
Place the `robbery_tablet.png` in `qb-inventory/html/images/`.

---

## Creator Custom Node (Required)

The tablet sends a start request to Quasar Robberies Creator through a custom trigger node. You must add this node to your **installed** `qs-robberies-creator` resource.

### Step 1: Back Up Creator

Make a backup of your `qs-robberies-creator` folder before editing.

### Step 2: Create the Node File

Create this file inside your Creator resource:

```
qs-robberies-creator/server/custom/nodes/tablet_start.lua
```

Paste the complete `tablet_start.lua` file from the `bxnde-robberies-tablet` resource

### Step 3: Ensure the File Loads

Check your Creator's (for example the qs-robberies-creator) `fxmanifest.lua`. If it does not automatically load files under `server/custom/nodes/`, add:

```lua
server_script 'server/custom/nodes/tablet_start.lua'
```

### Step 4: Restart and Configure

1. Restart `qs-robberies-creator`, then restart `bxnde-robberies-tablet`.
2. Open Robberies Creator and edit each robbery you want to launch from the tablet.
3. Add **Tablet Start** as a trigger node for that robbery.
4. Save the robbery. Make sure its ID or name matches the robbery entry the tablet reads from `qs_robberies`.

> **Common error:** `RegisterCustomNode: def requires kind and nodeType`. This means you used an old signature or the file loaded before the function was defined. Use the definition-table format from the README and confirm load order .

---

## Configuration Highlights

All settings are in `config/main.lua`:

| Setting | What It Does |
|---------|-------------|
| `Config.TabletItem` | Item name required to open (or `false` to disable) |
| `Config.CooldownMode` | `global`, `personal`, or `job` |
| `Config.PoliceJobs` | Jobs counted as police |
| `Config.RequirePoliceOnline` | Block starts when no police are online |
| `Config.RateLimit` | Minimum milliseconds between requests |
| `Config.StartLockSeconds` | Prevents the same robbery from starting repeatedly |
| `Config.StartEvent` | Event emitted to Creator (default: `bxnde-robberies-tablet:customstart`) |

Discord webhooks are in `server/custom/webhooks/main.lua`.

---

## What the Server Checks

The server never trusts the client. Every list and start request is validated for:

- Rate limit per player
- Player online, spawned, and alive
- Framework identity exists
- Tablet item (if required)
- Robbery ID resolved from the server-side list (never interpolated into SQL)
- Cooldown status
- Police online (if enabled)
- Required items extracted from the robbery graph
- Start lock to prevent spam

Failed checks reject the request. Missing bridges or database errors also reject.

---

## Database

| Table | Purpose | Default Columns |
|-------|---------|-----------------|
| `qs_robberies` | Robbery definitions | `id`, `name`, `data` |
| `qs_robbery_cooldowns` | Cooldown tracking | `robbery_id`, `identifier`, `job`, `expires_at` |

Robbery data is cached for `Config.CacheSeconds` (default configurable).

---

## Troubleshooting

| Problem | Check |
|---------|-------|
| Tablet won't open | F8 console, command/key config, `web/build/index.html` exists |
| Robbery list empty | oxmysql running, table name, column names in config |
| Robberies always available | Cooldown table, `expires_at` format (Unix seconds) |
| Item not recognised | `Config.Inventory` setting, exact item name in your inventory |
| `RegisterCustomNode: def requires kind and nodeType` | Use the definition-table code, ensure Creator loads the file after `RegisterCustomNode` is defined |
| Robbery doesn't start | **Tablet Start** saved as trigger, `tablet_start.lua` loaded by Creator, ID/name matches |
| No notifications | `Config.Notify` and matching notification resource |

Enable `Config.Debug = true` for detailed logs prefixed with `[bxnde-robberies-tablet][MODULE]`.

---

## Commands & Events

### Open Tablet (Client)

```lua
TriggerEvent('bxnde-robberies-tablet:opentablet')
```

### Start Request (Server Event)

```lua
AddEventHandler('bxnde-robberies-tablet:customstart', function(source, robberyId, row)
    -- The custom node in qs-robberies-creator resolves the matching trigger
    -- and calls start(source) to begin the robbery.
end)
```

### Creator Notifications (if supported by your Creator version)

```lua
TriggerClientEvent('qs-robberies:notify', source, 'The vault is open', 'success', 5000)
-- type: info, success, warning, error; duration in milliseconds
```

---

## UI Customization

The loaded file is `web/build/index.html`. Source files are under `web/src`. If you modify the source, rebuild from the `web/` folder with the package scripts and ensure the built file is included in the resource.

---

## Discord Logging

Logs use Discord Components V2 with a dark navy `#000B4A` container. Each log includes category-specific headings, player details (FiveM name, IC name, server ID, framework ID, job, available identifiers), robbery details, reward info, and a timestamp footer.

Player identifiers are shown in copyable code blocks. Discord users are mentioned when a Discord ID is available. **No player tokens are collected or logged.**

Configure webhooks in `server/custom/webhooks/main.lua`.
