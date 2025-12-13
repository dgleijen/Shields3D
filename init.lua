local IFORGE = assert(rawget(_G, "itemforge3d"), "itemforge3d API not found")

IFORGE.register("shields3d", "barbarian_shield", {
    description = "Barbarian Shield",
    type = "tool",
    inventory_image = "shields3d_barbarian_inv.png",
    slot = "shield",
    stats = {
        { type = "defense",    value = core.settings:get("shields3d_barbarian_defense") or 15, modifier = "add" },
        { type = "block",      value = core.settings:get("shields3d_barbarian_block") or 5,   modifier = "add" },
        { type = "durability", value = 100, modifier = "set" } -- start at 100%
    },
    attach_model = {
        properties = {
            visual = "mesh",
            mesh = "shields3d_barbarian.glb",
            textures = {"shields3d_barbarian.png"},
            visual_size = {x=1, y=1},
        },
        attach = {
            bone = "Arm_Left",
            position = {x=1, y=7, z=1.5},
            rotation = {x=0, y=-45, z=180},
            forced_visible = false
        }
    },
    on_use = function(itemstack, user, pointed_thing)
        local ok = IFORGE.equip(user, itemstack)
        return itemstack
    end
})

-- Damage reduction + durability
minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 and reason.type == "punch" then
        local stats = IFORGE.get_stats(player)
        local defense    = stats.defense or 0
        local block      = stats.block or 0
        local durability = stats.durability or 100

        local reduced = hp_change * (1 - defense / 100)

        if block > 0 and math.random(100) <= block then
            local equipped = IFORGE.get_slot(player, "shield")
            if equipped and equipped.stack then
                local wear = equipped.def.block_wear or (65535 / 100)
                equipped.stack:add_wear(wear)
                local current_wear = equipped.stack:get_wear()
                local percent = math.max(0, 100 - (current_wear / 65535) * 100)
                stats.durability = percent

                if equipped.stack:is_empty() or percent <= 0 then
                    IFORGE.unequip(player, "shield")
                end
            end
            reduced = 0
        end

        return reduced
    end
    return hp_change
end, true)

-- Knockback scaling
local old_calculate_knockback = core.calculate_knockback
function core.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
    local knockback = old_calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)

    local stats = IFORGE.get_stats(player)
    local defense    = stats.defense or 0
    local block      = stats.block or 0

    if block > 0 and math.random(100) <= block then
        return {x=0, y=0, z=0}
    end

    if defense > 0 then
        knockback = vector.multiply(knockback, 1 - defense / 100)
    end

    return knockback
end