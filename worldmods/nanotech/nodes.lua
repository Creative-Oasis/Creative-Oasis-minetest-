local CHEST_FORMSPEC =
    "size[20,12]" ..
    "list[current_name;main;0,0;20,7;]" ..
    "list[current_player;main;6,8;8,4;]" ..
    "listring[current_name;main]" ..
    "listring[current_player;main]"

-- =====================
-- Carbon Chest Node
-- =====================
minetest.register_node("nanotech:carbon_chest", {
    description = "Carbon Composite Chest",
    tiles = {
        "carbon_chest_top.png",
        "carbon_chest.png",
        "carbon_chest.png",
        "carbon_chest.png",
        "carbon_chest.png",
        "carbon_chest_front.png"
    },
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_wood_defaults(),

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", CHEST_FORMSPEC)
        meta:set_string("infotext", "Carbon Chest")
        meta:get_inventory():set_size("main", 20 * 7)
    end,

    can_dig = function(pos, player)
        return player
            and minetest.get_meta(pos):get_inventory():is_empty("main")
    end,

    on_rightclick = function(pos, node, player)
        if not player then return end
        local name = player:get_player_name()

        if minetest.is_protected(pos, name) then
            minetest.chat_send_player(name,
                "This chest is protected. You are not allowed to access it.")
            return
        end

        minetest.show_formspec(
            name,
            "nodemeta:" .. minetest.pos_to_string(pos),
            minetest.get_meta(pos):get_string("formspec")
        )
    end,

    allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
        if player and minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return count
    end,

    allow_metadata_inventory_put = function(pos, _, _, stack, player)
        if player and minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return stack:get_count()
    end,

    allow_metadata_inventory_take = function(pos, _, _, stack, player)
        if player and minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return stack:get_count()
    end,
})

-- =====================
-- ONE-TIME LBM FIX
-- =====================
minetest.register_lbm({
    label = "Fix Carbon Chest Formspec (Shift+Click)",
    name = "nanotech:fix_carbon_chest_formspec",
    nodenames = {"nanotech:carbon_chest"},
    run_at_every_load = false, -- IMPORTANT: runs only once
    action = function(pos)
        local meta = minetest.get_meta(pos)

        -- Only update old/broken chests
        if meta:get_string("formspec") ~= CHEST_FORMSPEC then
            meta:set_string("formspec", CHEST_FORMSPEC)
        end

        -- Ensure inventory exists
        local inv = meta:get_inventory()
        if inv:get_size("main") ~= 20 * 7 then
            inv:set_size("main", 20 * 7)
        end
    end,
})
