# Shields3D API

Shields3D is a Minetest API for registering and managing 3D shield items. It integrates with `armorforge` and `itemforge3d` to provide equip/unequip logic, persistence, and dynamic item registration.

## Overview
- Register shields with dynamic prefixed names (`modname_name`).
- Define custom armor stats and attach model data.
- Equip/unequip lifecycle handled automatically.
- Equipped shields are restored when players rejoin.

## API

### `SHIELDS3D.register_shield(modname, name, overrides)`
Registers a new shield item.

**Parameters:**
- `modname` *(string)*: The current mod name.
- `name` *(string)*: Base name of the shield (e.g. `"spiked"`).
- `overrides` *(table)*: Fields you can override.

**You can override:**
- `description` *(string)*: Display name of the shield.
- `armor` *(table)*: Armor stats such as `{ armor=15, block=5, knockback=2 }`.
- `attach_model` *(table)*: Positioning data for how the shield attaches to the player model:
  ```lua
  attach_model = {
      attach = {
          bone = "Arm_Left",
          pos = {x=1, y=7, z=1.5},
          rot = {x=0, y=-45, z=180},
          force_visible = false,
      }
  }
  ```

### Lifecycle Hooks
- **Equip:** Automatically attaches the shield entity when equipped.
- **Unequip:** Detaches the entity and returns the item to inventory or drops it if full.
- **Chat Command:** `/unequip shield` unequips armor from a specific slot.
- **Re-equip on Join:** Shields are re-attached when a player rejoins.

## Example
```lua
local shields = {
    {
        name = "spiked",
        description = "Spiked Shield",
        armor = { armor = 15, block = 5, knockback = 2 },
        attach_model = {
            attach = {
                bone = "Arm_Left",
                pos = {x=1, y=7, z=1.5},
                rot = {x=0, y=-45, z=180},
                force_visible = false,
            }
        },
    },
}

for _, def in ipairs(shields) do
    shields3d.register_shield(MODNAME, def.name, def)
end
```

## Notes
- Only override what you need: description, armor stats, and attach model.
- Item IDs are automatically prefixed with the mod name.
- Equip/unequip logic is shield-specific.

