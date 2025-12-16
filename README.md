# Shields3D

**Shields3D** is a Minetest API for registering and managing 3D shield items.  
It integrates with [`armorforge`](https://content.minetest.net/packages/luanti/armorforge/) and [`itemforge3d`](https://content.minetest.net/packages/luanti/itemforge3d/) to provide equip/unequip logic, persistent attachment, sound effects, and dynamic item registration.

---

## Features

- Register shields with dynamic prefixed names (`modname:name`)
- Supports both **`mesh`** and **`wielditem`** visual modes
- Define custom armor stats, textures, and 3D models
- Sneak + right-click to equip shields from inventory
- Automatic equip/unequip lifecycle with sound playback
- Shields reattach automatically when players rejoin
- Chat command to unequip shields manually

---

## API

### `SHIELDS3D.register_shield(modname, name, overrides, wield_mode)`

Registers a new shield item.

#### Parameters:
- `modname` *(string)*: Your mod name (e.g. `"shields3d"`)
- `name` *(string)*: Base name of the shield (e.g. `"spiked"`)
- `overrides` *(table)*: Optional table to override default fields
- `wield_mode` *(string)*: `"mesh"` or `"wielditem"` (default: `"mesh"`)

#### You can override:

| Field         | Type     | Description |
|---------------|----------|-------------|
| `description` | string   | Display name of the shield |
| `armor`       | table    | Armor stats: `{ armor=0, block=0, knockback=0, speed_walk=0, gravity=0 }` |
| `properties`  | table    | Visuals: `mesh`, `textures`, `wield_item`, `visual_size`, etc. |
| `attach`      | table    | Attachment data (bone, position, rotation, visibility) |

---

## Visual Modes

### `"mesh"`
- Uses a `.glb` model (e.g. `dragonsteel.glb` in `models/`)
- Requires `textures = { "your_texture.png" }`
- Best for detailed fantasy shields

### `"wielditem"`
- Uses a wielded item node with `inventory_image` and `wield_item`
- Best for simple shields or 2D-style visuals

---

## Lifecycle Hooks

- **Equip**: Sneak + right-click to equip. Attaches the shield entity and plays a randomized equip sound.
- **Unequip**: Detaches the shield, plays a sound, and returns it to inventory or drops it.
- **Rejoin**: Shields are silently reattached on player join (no sound).
- **Chat Command**: `/unequip shield` removes the shield from the player.

---

## Sound Effects

- Equip and unequip sounds are played using `core.sound_play("equip", { ... })`
- Pitch and gain are randomized slightly for variation:
  ```lua
  core.sound_play("equip", {
      to_player = player:get_player_name(),
      gain = math.random(8, 12) / 10.0,
      pitch = math.random(95, 105) / 100.0,
  })
  ```
- Place `equip.ogg` in your mod’s `sounds/` folder

---

## Example: Both `wielditem` and `mesh`

```lua
local shields = {
    {
        name = "oakwood",
        description = "Oakwood Shield",
        armor = { armor = 10, block = 3 },
        properties = {
            visual = "wielditem",
            wield_item = "shields3d:oakwood",
            visual_size = {x=0.4, y=0.4, z=0.25},
            inventory_image = "oakwood.png",
        },
        attach = {
            bone = "Arm_Left",
            pos = {x=1, y=4.5, z=1.5},
            rot = {x=0, y=-45, z=180},
            force_visible = false,
        },
        wield_mode = "wielditem",
    },
    {
        name = "dragonsteel",
        description = "Dragonsteel Shield",
        armor = { armor = 20, block = 8, knockback = 2 },
        properties = {
            visual = "mesh",
            visual_size = {x=1, y=1},
            textures = { "dragonsteel_texture.png" },
        },
        attach = {
            bone = "Arm_Left",
            pos = {x=1, y=4.5, z=1.5},
            rot = {x=0, y=-45, z=180},
            force_visible = false,
        },
        wield_mode = "mesh",
    },
}

for _, def in ipairs(shields) do
    shields3d.register_shield(MODNAME, def.name, def, def.wield_mode)
end
```

---

## File Structure

```
shields3d/
├── init.lua
├── models/
│   └── dragonsteel.glb
├── textures/
│   ├── oakwood.png
│   └── dragonsteel_texture.png
├── sounds/
│   └── equip.ogg
└── README.md
```

---

## Notes

- Only override what you need — defaults are provided for armor, visuals, and attachment
- Item IDs are automatically prefixed with your mod name
- Equip logic is triggered only when the player sneaks and right-clicks with the shield
- Re-equip on join is silent (no sound)
- You can mix `mesh` and `wielditem` shields in the same mod
- Equip/unequip logic is shield-specific and handled automatically

---

With this setup, you can create both **simple 2D-style shields** (`wielditem`) and **full 3D fantasy shields** (`mesh`) in the same mod.
```
