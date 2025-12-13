local IFORGE = assert(rawget(_G, "itemforge3d"), "itemforge3d API not found")

local settings = {
    barbarian_shield = {
        defense = tonumber(minetest.settings:get("shields3d_barbarian_defense")) or 15,
        block   = tonumber(minetest.settings:get("shields3d_barbarian_block")) or 5,
    }
}

IFORGE.register("shields3d", "barbarian_shield", {
    description = "Barbarian Shield",
    type = "tool",
    inventory_image = "shields3d_barbarian_inv.png",
    slot = "shield",
    stats = {
        { type = "defense", value = settings.barbarian_shield.defense, modifier = "add" },
        { type = "block",   value = settings.barbarian_shield.block, modifier = "add" }
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
        if ok then
            return itemstack
        end
        return itemstack
    end
})

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 and reason.type == "punch" then

            local stats = IFORGE.get_stats(player)
            local defense = stats.defense or 0 
            local block   = stats.block or 0
            local reduced = hp_change * (1 - defense / 100)
            if block > 0 and math.random(100) <= block then
                reduced = 0
                minetest.chat_send_player(player:get_player_name(), "Blocked the attack!")
            end

            return reduced
        end

    return hp_change
end, true)
