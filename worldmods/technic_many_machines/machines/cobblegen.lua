local S = core.get_translator("technic_many_machines")
--function for cobble gen

--register recipe type 
technic.register_recipe_type("cobblestone_generating", {
    description = S("Cobblestone Generating"),
    icon = "default_cobble.png",
    input_size = 1,
})
--register recipe
technic.register_recipe("cobblestone_generating", {
    input = {""},
    output = {"default:cobble"},
    time = 1
})

--LV cobble gen
technic.register_base_machine("technic_many_machines:lv_cobble_generator", {
    typename = "cobblestone_generating",
    description = S("LV Cobblestone Generator"),
    tier = "LV", 
    speed = 1,
    demand = {300}
})
core.override_item("technic_many_machines:lv_cobble_generator", {
    tiles = {
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_bottom.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_cobblestone_generator.png",
        }
})
core.override_item("technic_many_machines:lv_cobble_generator_active", {
    tiles = {
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_bottom.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
        "technic_many_machines_lv_side.png",
         {name = "technic_many_machines_lv_cobblestone_generator_active.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1, }, 
        },
    }
})
--MV cobble gen
technic.register_base_machine("technic_many_machines:mv_cobble_generator", {
    typename = "cobblestone_generating",
    description = S("MV Cobblestone Generator"),
    tier = "MV", 
    speed = 3,
    demand = {900, 750, 600},
    upgrade = 1,
    tube = 1,
})
core.override_item("technic_many_machines:mv_cobble_generator", {
    tiles = {
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png", 
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_cobblestone_generator.png",
        }
})
core.override_item("technic_many_machines:mv_cobble_generator_active", {
    tiles = {
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png", 
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
         {name = "technic_many_machines_mv_cobblestone_generator_active.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1, }, 
        },
    }
})

--HV cobble gen
technic.register_base_machine("technic_many_machines:hv_cobble_generator", {
    typename = "cobblestone_generating",
    description = S("HV Cobblestone Generator"),
    tier = "HV", 
    speed = 9,
    demand = {2700, 2250, 1800},
    upgrade = 1,
    tube = 1,
})
core.override_item("technic_many_machines:hv_cobble_generator", {
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_bottom.png",
        "technic_many_machines_hv_side.png", 
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_cobblestone_generator.png",
        }
})
core.override_item("technic_many_machines:hv_cobble_generator_active", {
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_bottom.png",
        "technic_many_machines_hv_side.png", 
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_side.png",
         {name = "technic_many_machines_hv_cobblestone_generator_active.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1, }, 
        },
    }
})
if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:hv_cobble_generator", "technic_many_machines:hv_cobble_generator_active", "technic_many_machines:mv_cobble_generator", "technic_many_machines:mv_cobble_generator_active"}, {
        on_pull_item = function(pos, out_dir, count)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.get_items(pos, inv, "dst", count)
        end,
        on_unpull_item = function(pos, out_dir, stack)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.put_items(inv, "dst", stack)
        end,
    })
end
