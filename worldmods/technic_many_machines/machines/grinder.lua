
local S = core.get_translator("technic_many_machines")

technic.register_base_machine("technic_many_machines:hv_grinder_mk2", {
    typename = "grinding",
    description = S("HV Grinder Mk2"),
    demand = {18000, 14000, 10000},
    speed = 25,
    tube = 1,
    upgrade = 1,
    tier = "HV"
})

local animtiles = {
    name = "technic_many_machines_hv_grinder_mk2_front_active.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 0.5,
    },
}

core.override_item("technic_many_machines:hv_grinder_mk2_active", {
    description = S("HV Grinder Mk2 (Active)"),
    tiles = {
        "technic_many_machines_forge_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_machine_bottom_mk2.png",
        "technic_many_machines_hv_grinder_mk2_side.png",
        "technic_many_machines_hv_grinder_mk2_side.png",
        "technic_many_machines_hv_grinder_mk2_side.png",
        animtiles,
}})
core.override_item("technic_many_machines:hv_grinder_mk2", {
    tiles = {
        "technic_many_machines_forge_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_machine_bottom_mk2.png",
        "technic_many_machines_hv_grinder_mk2_side.png",
        "technic_many_machines_hv_grinder_mk2_side.png",
        "technic_many_machines_hv_grinder_mk2_side.png",
        "technic_many_machines_hv_grinder_mk2_front.png",
}})

if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:hv_grinder_mk2", "technic_many_machines:hv_grinder_mk2_active"}, {
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