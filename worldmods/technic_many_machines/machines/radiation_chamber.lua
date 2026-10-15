local S = core.get_translator("technic_many_machines")
technic.register_recipe_type("radiation_chamber", {
    description = S("Irradiating"),
    icon = "technic_many_machines_hv_radiation_chamber.png",
    input_size = 1,
    output_size = 2,

})
technic.register_base_machine("technic_many_machines:hv_radiation_chamber", {
    typename = "radiation_chamber",
    description = S("HV Radiation Chamber"),
    tier = "HV", 
    speed = 1,
    demand = {11000, 9000, 7000},
    upgrade = 1,
    tube = 1,
})
core.override_item("technic_many_machines:hv_radiation_chamber", {
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_bottom.png",
        "technic_many_machines_hv_radiation_chamber.png",
        "technic_many_machines_hv_radiation_chamber.png",
        "technic_many_machines_hv_radiation_chamber.png",
        "technic_many_machines_hv_radiation_chamber.png",
    }
})
local animtiles = {
    name = "technic_many_machines_hv_radiation_chamber_active.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5,
    },
}

core.override_item("technic_many_machines:hv_radiation_chamber_active", {
    tiles = {
        "technic_many_machines_hv_side.png",
        "technic_many_machines_hv_bottom.png",
        animtiles,
        animtiles,
        animtiles,
        animtiles,
    },
    light_source = 11,
})
if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:hv_radiation_chamber", "technic_many_machines:hv_radiation_chamber_active"}, {
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