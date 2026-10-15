comod_shields = {}

local privs = {
    "comod_admin",
    "comod_staff",
    "comod_builder",
    "comod_contributor"
}

for _, p in ipairs(privs) do
    minetest.register_privilege(p, {
        description = "comod_shields privilege: " .. p,
        give_to_singleplayer = true,
    })
end

local function no_drop(itemstack)
    return itemstack
end

minetest.register_tool("comod_shields:shield_staff", {
    description = "Staff Shield",
    inventory_image = "shield_inv_staff.png",
    --wield_image = "shield_staff.png",
    groups = {armor_shield=1, armor_heal=14.5, armor_use=0, physics_jump=0.10,physics_speed=0.20,armor_fire = 1,radiation =25,armor_water=1,},
	armor_groups = {fleshy=20, radiation=100},
    on_drop = no_drop,
})

minetest.register_tool("comod_shields:shield_builder", {
    description = "Builder Shield",
    inventory_image = "shield_inv_builder.png",
    --wield_image = "shield_builder.png",
    groups = {armor_shield=1, armor_heal=100, armor_use=0, physics_jump=0.10,physics_speed=0.20,armor_fire = 1,radiation =25,armor_water=1,},
	armor_groups = {fleshy=50, radiation=1000},
    on_drop = no_drop,
})

minetest.register_tool("comod_shields:shield_contributor", {
    description = "Contributor Shield",
    inventory_image = "shield_inv_contributor.png",
    --wield_image = "shield_contributor.png",
    groups = {armor_shield=1, armor_heal=12, armor_use=0, physics_jump=0.10,physics_speed=0.20,armor_fire = 1,radiation =25,armor_water=1,},
	armor_groups = {fleshy=18, radiation=100},
    on_drop = no_drop,
})

local restricted_items = {
    ["3d_armor:helmet_admin"] = "comod_admin",
    ["3d_armor:chestplate_admin"] = "comod_admin",
    ["3d_armor:leggings_admin"] = "comod_admin",
    ["3d_armor:boots_admin"] = "comod_admin",
    ["shields:shield_admin"] = "comod_admin",
    ["comod_shields:shield_staff"] = "comod_staff",
    ["comod_shields:shield_builder"] = "comod_builder",
    ["comod_shields:shield_contributor"] = "comod_contributor",
}

local warned_players = {}

local function remove_illegal_items(player)
    if not player or not player:is_player() then return end
    local inv = player:get_inventory()
    if not inv then return end
    local priv = minetest.get_player_privs(player:get_player_name())

    local size = inv:get_size("main")
    if not size then return end

    for i = 1, size do
        local stack = inv:get_stack("main", i)
        if stack and not stack:is_empty() then
            local ok, item = pcall(function() return stack:get_name() end)
            if ok and item then
                local need = restricted_items[item]
                if need and not priv[need] then
                    inv:set_stack("main", i, ItemStack(""))
                    local pname = player:get_player_name()
                    warned_players[pname] = warned_players[pname] or {}
                    if not warned_players[pname][item] then
                        minetest.chat_send_player(pname,
                            "You cannot take this armor due to lack of privilege: " .. need)
                        warned_players[pname][item] = true
                    end
                end
            end
        end
    end
end

minetest.register_on_player_inventory_action(function(player)
    minetest.after(0, function()
        remove_illegal_items(player)
    end)
end)

minetest.register_on_joinplayer(function(player)
    minetest.after(0, function()
        remove_illegal_items(player)
    end)
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        remove_illegal_items(player)
    end
end)