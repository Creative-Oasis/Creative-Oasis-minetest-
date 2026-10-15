--compressor, but faster and has two slots now for annoying people
-- for whatever reason you want to make your own mass compressor
local S = core.get_translator("technic_many_machines")

technic.register_recipe_type("bulk_compressing", {
    description = S("Bulk Compressing"),
    icon = "technic_many_machines_hv_masscompressor_front.png",
    input_size = 2
})

technic.register_base_machine("technic_many_machines:hv_masscompressor", {
    description = S("HV Mass Compressor") .. "\n" .. core.colorize("#84bac1ff", S("Compresses items in bulk with new recipes")),
    typename = "bulk_compressing",
    tier = "HV",
    demand = {6000, 4500, 3000},
    speed = 1,
    upgrade = 1,
    tube = 1
})

core.override_item("technic_many_machines:hv_masscompressor_active", {
    tiles = {
        "technic_many_machines_hv_masscompressor_top.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_masscompressor_bottom.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_masscompressor_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_masscompressor_side.png^pipeworks_tube_connection_metallic.png",
        "technic_many_machines_hv_masscompressor_side.png^pipeworks_tube_connection_metallic.png",
         {name = "technic_many_machines_hv_masscompressor_front_active.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1, }, },
        }})

function technic_many_machines.register_bulk_compressor_recipe(data)
    data.time = data.time or 4
    technic.register_recipe("bulk_compressing", data)
end

if core.get_modpath("techage") then
    techage.register_node({"technic_many_machines:hv_masscompressor", "technic_many_machines:hv_masscompressor_active"}, {
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
