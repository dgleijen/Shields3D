local DEFAULT_SLOT = "shield"
local STANDARD_TYPE = "tool"
local STANDARD_VISUAL = "mesh"
local STANDARD_SIZE = {x=1, y=1}
local MODNAME = core.get_current_modname()

local SHIELDS3D = {}
shields3d = {}
local afapi = armorforge.api



local function osu(itemstack, user, pointed_thing)
    if afapi.has_equipped(user, DEFAULT_SLOT) then
        core.chat_send_player(user:get_player_name(), "You already have a shield equipped!")
    else
        afapi.equip(user, itemstack, DEFAULT_SLOT)
        itemstack:take_item(1)
    end
    return itemstack
end

local function register_with_attach_model(modname, name, def)
    if def.attach_model then
        def.attach = def.attach or def.attach_model.attach
        if not def.attach then
            core.log("warning", "[itemforge3d] attach_model provided but no attach data found.")
        end
        itemforge3d.register(modname, name, def)
    end
end

local function make_item_id(modname, name)
    return modname .. "_" .. name
end

local function merge_tables(base, overrides)
    local result = table.copy(base)
    for k,v in pairs(overrides or {}) do
        if type(v) == "table" and type(result[k]) == "table" then
            for kk,vv in pairs(v) do
                result[k][kk] = vv
            end
        else
            result[k] = v
        end
    end
    return result
end

function SHIELDS3D.register_shield(modname, name, overrides)
    local item_id = make_item_id(modname, name)

    local base_def = {
        description = "Shield",
        type = STANDARD_TYPE,
        inventory_image = item_id .. "_inv.png",
        slot = DEFAULT_SLOT,
        armor = overrides.armor or { armor = 0, block = 0, knockback = 0, speed_walk = 0, gravity = 0 },
        properties = {
            visual = STANDARD_VISUAL,
            mesh = item_id .. ".glb",
            textures = { item_id .. ".png" },
            visual_size = STANDARD_SIZE,
        },
        attach_model = overrides.attach_model,
        on_secondary_use = osu,
    }

    local def = merge_tables(base_def, overrides)
    register_with_attach_model(modname, item_id, def)
end


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
    SHIELDS3D.register_shield(MODNAME, def.name, def)
end

afapi.register_on_equip(function(player, stack, slot)
    if slot == DEFAULT_SLOT then
        itemforge3d.attach_entity(player, stack, { id = slot })
    end
end)

afapi.register_on_unequip(function(player, stack, slot)
    if slot == DEFAULT_SLOT then
        itemforge3d.detach_entity(player, stack:get_name())
    end
    if stack and stack:get_count() > 0 then
        local inv = player:get_inventory()
        if inv and inv:room_for_item("main", stack) then
            inv:add_item("main", stack)
        else
            core.item_drop(stack, player, player:get_pos())
        end
    end
end)

core.register_chatcommand("unequip", {
    params = "<slot>",
    description = "Unequip armor from a specific slot (helmet, chest, leggings, boots, shield)",
    privs = {},
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Player not found."
        end

        local slot = param:lower()
        if not afapi.has_equipped(player, slot) then
            return false, "You have nothing equipped in the '" .. slot .. "' slot."
        end

        local success = afapi.unequip(player, slot)
        if success then
            return true, "Unequipped item from slot '" .. slot .. "'."
        else
            return false, "Failed to unequip from slot '" .. slot .. "'."
        end
    end
})

local function re_equip_all(player)
    if not player then return end
    local equipped = afapi.get_equipped(player)
    if not equipped then return end

    for slot, stack in pairs(equipped) do
        if slot == DEFAULT_SLOT and stack and not stack:is_empty() then
            itemforge3d.attach_entity(player, stack, { id = slot })
        end
    end
end

core.register_on_joinplayer(function(player)
    core.after(1.0, function()
        re_equip_all(player)
    end)
end)

shields3d = SHIELDS3D