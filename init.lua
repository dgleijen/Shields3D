local DEFAULT_SLOT    = "shield"
local STANDARD_TYPE   = "tool"
local STANDARD_VISUAL = "mesh"
local STANDARD_SIZE   = {x=1, y=1}
local MODNAME         = core.get_current_modname()

local SHIELDS3D = {}
shields3d = {}
local afapi = armorforge.api
local re_equipping = {}

local function osu(itemstack, user, pointed_thing)
    if user:get_player_control().sneak then
        if afapi.has_equipped(user, DEFAULT_SLOT) then
            core.chat_send_player(user:get_player_name(), "You already have a shield equipped!")
        else
            afapi.equip(user, itemstack, DEFAULT_SLOT)
            itemstack:take_item(1)

            core.sound_play("equip", {
                to_player = user:get_player_name(),
                gain = math.random(8, 12) / 10.0,
                pitch = math.random(95, 105) / 100.0,
            })
        end
        return itemstack
    end
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

function SHIELDS3D.register_shield(modname, name, overrides, wield_mode)
    local item_id = modname .. ":" .. name
    local visual_mode = wield_mode or STANDARD_VISUAL

    local base_def = {
        description = "Shield",
        type = STANDARD_TYPE,
        inventory_image = name .. ".png",
        armor = { armor = 0, block = 0, knockback = 0, speed_walk = 0, gravity = 0 },
        properties = {
            visual = visual_mode,
            visual_size = STANDARD_SIZE,
        },
        on_secondary_use = osu,
    }

    if visual_mode == "mesh" then
        base_def.properties.mesh = name .. ".glb"
    elseif visual_mode == "wielditem" then
        base_def.properties.wield_item = item_id
        base_def.properties.visual_size = {x=0.667, y=0.667}
    end

    local def = merge_tables(base_def, overrides or {})

    itemforge3d.register(modname, name, def)
end

local AMOUNT = 4
local SHIELDS = {}

for i = 1, AMOUNT do
    local shield = {
        name = "shield_" .. i,
        description = "Shield " .. i,
        properties = {
            visual = "wielditem",
            wield_item = "shields3d:shield_" .. i,
            visual_size = {x=0.4, y=0.4, z=0.25},
            inventory_image = "shield_" .. i .. ".png",
        },
        attach = {
            bone = "Arm_Left",
            pos  = {x=1, y=4.5, z=1.5},
            rot  = {x=0, y=-45, z=180},
            force_visible = false,
        },
    }
    table.insert(SHIELDS, shield)
end

for _, def in ipairs(SHIELDS) do
    SHIELDS3D.register_shield(MODNAME, def.name, def)
end

afapi.register_on_equip(function(player, stack, slot)
    if slot == DEFAULT_SLOT then
        itemforge3d.attach_entity(player, stack, { id = slot })
    end
end)

afapi.register_on_unequip(function(player, stack, slot)
    if slot == DEFAULT_SLOT then
        itemforge3d.detach_entity(player, slot)
        core.sound_play("unequip", {
            to_player = player:get_player_name(),
            gain = math.random(8, 12) / 10.0,
            pitch = math.random(95, 105) / 100.0,
        })
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

core.register_chatcommand("equip", {
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
    local pname = player:get_player_name()
    re_equipping[pname] = true

    local equipped = afapi.get_equipped(player)
    if not equipped then return end

    for slot, stack in pairs(equipped) do
        if slot == DEFAULT_SLOT and stack and not stack:is_empty() then
            itemforge3d.attach_entity(player, stack, { id = slot })
        end
    end
    core.after(0.1, function() re_equipping[pname] = nil end)
end


core.register_on_mods_loaded(function()
    core.register_on_joinplayer(function(player)
        core.after(1.0, function()
            re_equip_all(player)
        end)
    end)
end)

shields3d = SHIELDS3D