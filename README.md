# Shields3D API

Shields3D is a Minetest API for registering and managing 3D shield items. It integrates with `armorforge` and `itemforge3d` to provide equip/unequip logic, persistence, sound effects, and dynamic item registration.

## Overview
- Register shields with dynamic prefixed names (`modname:name`).
- Define custom armor stats, visuals, and attach data.
- Equip/unequip lifecycle handled automatically.
- Equipped shields are restored when players rejoin.
- Optional sound playback on equip/unequip with subtle variation.

## API

### `SHIELDS3D.register_shield(modname, name, overrides, wield_mode)`
Registers a new shield item.

**Parameters:**
- `modname` *(string)*: The current mod name.
- `name` *(string)*: Base name of the shield (e.g. `"spiked"`).
- `overrides` *(table)*: Fields you can override.
- `wield_mode` *(string, optional)*: Either `"mesh"` or `"wielditem"` to control how the shield is rendered.

**You can override:**
- `description` *(string)*: Display name of the shield.
- `armor` *(table)*: Armor stats such as `{ armor=15, block=5, knockback=2 }`.
- `properties` *(table)*: Visual properties, e.g. `mesh`, `wield_item`, `visual_size`, `textures`.
- `attach` *(table)*: Positioning data for how the shield attaches to the player model:
  ```lua
  attach = {
      bone = "Arm_Left",
      pos = {x=1, y=4.5, z=1.5},
      rot = {x=0, y=-45, z=180},
      force_visible = false,
  }
  ```

### Lifecycle Hooks
- **Secondary Use (`osu`)**: Sneak + right-click equips the shield if the slot is empty.
- **Equip:** Automatically attaches the shield entity when equipped, and plays a sound with randomized pitch/gain.
- **Unequip:** Detaches the entity, plays a sound, and returns the item to inventory or drops it if full.
- **Chat Command:** `/unequip shield` unequips armor from a specific slot.
- **Re-equip on Join:** Shields are re-attached silently when a player rejoins (no sound).

## Example
```lua
local shields = {
    {
        name = "spiked",
        description = "Spiked Shield",
        armor = { armor = 15, block = 5, knockback = 2 },
        properties = {
            visual = "wielditem",
            wield_item = "shields3d:spiked",
            visual_size = {x=0.4, y=0.4, z=0.25},
            inventory_image = "spiked.png",
        },
        attach = {
            bone = "Arm_Left",
            pos = {x=1, y=4.5, z=1.5},
            rot = {x=0, y=-45, z=180},
            force_visible = false,
        },
    },
}

for _, def in ipairs(shields) do
    shields3d.register_shield(MODNAME, def.name, def, "wielditem")
end
```

## Notes
- Only override what you need: description, armor stats, properties, and attach data.
- Item IDs are automatically prefixed with the mod name.
- Equip/unequip logic includes sound playback with subtle variation.
- Re-equip on join restores shields without triggering sounds.

---

👉 This version reflects your latest code:  
- `osu` sneak logic for manual equip.  
- Sound playback with randomized pitch/gain.  
- `properties` and `attach` overrides instead of `attach_model`.  