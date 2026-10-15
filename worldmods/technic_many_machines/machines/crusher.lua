local S = core.get_translator("technic_many_machines")
technic.register_recipe_type("crushing", {
    description = S("Crushing"),
    inventory_image = "technic_many_machines_mv_crusher_front.png",
    input_size = 1,
    output_size = 4,
})
technic.register_base_machine("technic_many_machines:mv_crusher", {
    typename = "crushing",
    description = S("MV Crusher"),
    tier = "MV", 
    speed = 1,
    demand = {3000, 2000, 1000},
    upgrade = 1,
    tube = 1,
})
core.override_item("technic_many_machines:mv_crusher", {
    tiles = {
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_crusher_front.png",
    }
})
local animtiles = {
    name = "technic_many_machines_mv_crusher_front_active.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.25,
    },
}

core.override_item("technic_many_machines:mv_crusher_active", {
    tiles = {
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        "technic_many_machines_mv_side.png",
        animtiles,
    },
})

function technic_many_machines.register_crusher_recipe(data)
    data.time = data.time or 4
    technic.register_recipe("crushing", data)
end

if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:mv_crusher", "technic_many_machines:mv_crusher_active"}, {
        on_push_item = function(pos, in_dir, stack)
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            return techage.put_items(inv, "src", stack)
        end,
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
