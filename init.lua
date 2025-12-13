local physics = dofile(core.get_modpath(core.get_current_modname()) .. "/physx.lua")
local function register_with_attach_model(modname, name, def)
    if def.attach_model then
        def.properties = def.properties
        def.attach = def.attach or def.attach_model.attach
    end
    itemforge3d.register(modname, name, def)
end

register_with_attach_model("shields3d", "spiked_shield", {
    description = "Spiked Shield",
    type = "tool",
    inventory_image = "shields3d_spiked_inv.png",
    slot = "shield",
    armor = { armor = 2, block = 1, knockback = -0.2 },
    properties = {
            visual = "mesh",
            mesh = "shields3d_spiked.glb",
            textures = {"shields3d_spiked.png"},
            visual_size = {x=1, y=1},
        },
    attach_model = {
        attach = {
            bone = "Arm_Left",
            pos = {x=1, y=7, z=1.5},
            rot = {x=0, y=-45, z=180},
            force_visible = false,
        }
    },
    on_place = function(itemstack, user, pointed_thing)
        if armorforge.has_equipped(user, "shield") then
            minetest.chat_send_player(user:get_player_name(), "You already have a shield equipped!")
        else
            armorforge.equip(user, itemstack, "shield")
            itemforge3d.attach_entity(user, itemstack, { id = slot })
            itemstack:take_item(1)
        end
        
        return itemstack
    end,

})

armorforge.register_on_unequip(function(player, stack, slot)
    if stack and not stack:is_empty() then
        local inv = player:get_inventory()
        if inv and inv:room_for_item("main", stack) then
            inv:add_item("main", stack)
        else
            minetest.item_drop(stack, player, player:get_pos())
        end
    end
end)

minetest.register_chatcommand("unequip", {
    params = "<slot>",
    description = "Unequip armor from a specific slot (helmet, chest, leggings, boots, shield)",
    privs = {},
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local slot = param:lower()
        if not armorforge.has_equipped(player, slot) then
            return false, "You have nothing equipped in the '" .. slot .. "' slot."
        end

        local success = armorforge.unequip(player, slot)
        if success then
            return true, "Unequipped item from slot '" .. slot .. "'."
        else
            return false, "Failed to unequip from slot '" .. slot .. "'."
        end
    end
})

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 then
        local stats = armorforge.get_stats(player)
        local defense = stats.armor or 0
        local block   = stats.block or 0

        local reduced = hp_change * (1 - defense / 100)

        if block > 0 and math.random(100) <= block then
            local shield = armorforge.get_equipped_in_slot(player, "shield")
            if shield and not shield:is_empty() then
                local def = shield:get_definition()
                local wear = 1 + ((def and def.block_wear) or 0)
                shield:add_wear(wear)
            end
            return 0 
        end

        return reduced
    end

    return hp_change
end, true)

local old_knockback = core.calculate_knockback

function core.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
    local knockback = old_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)

    local stats = armorforge.get_stats(player)
    local defense = stats.armor or 0
    local block   = stats.block or 0

    if block > 0 and math.random(100) <= block then
        return {x=0, y=0, z=0}
    end

    if defense > 0 then
        knockback = vector.multiply(knockback, 1 - defense / 100)
    end

    return knockback
end
