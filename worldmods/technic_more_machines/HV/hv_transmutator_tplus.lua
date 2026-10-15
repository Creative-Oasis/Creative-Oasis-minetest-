--register recipe type
technic.register_recipe_type("trasmutating", {
    description = "Transmutating",
    icon = "technic_more_machines_hv_transmutator_front_active.png",
    input_size = 1
})
--register recipes
function technic.register_trasmutator_recipe(data)
    data.time = data.time or 4
    technic.register_recipe("trasmutating", data)
end
local recipes = {
    {"moreores:mithril_block 2", "technic:lead_block"},
    {"technic:lead_block 2", "default:goldblock"},
    {"default:goldblock 2", "default:tinblock"},
    {"default:tinblock 2", "moreores:silver_block"},
    {"moreores:silver_block 2", "technic:zinc_block"},
    {"technic:zinc_block 2", "default:copperblock"},
    {"default:copperblock 2", "default:steelblock"},
    {"default:steelblock 2", "technic:chromium_block"},
}
for _, data in pairs(recipes) do
    technic.register_trasmutator_recipe({input = { data[1] }, output = { data[2] } })
end
--register craft
minetest.register_craft({
	output = 'technic_more_machines:hv_transmutator',
	recipe = {
		{'technic:stainless_steel_block', 'technic:power_monitor',   'technic:stainless_steel_block'},
		{'technic:hv_transformer', 'technic:mv_centrifuge', 'technic:hv_transformer'},
		{'technic:lead_block', 'technic:hv_cable', 'technic:lead_block'},
	}
})
--register machine
technic.register_base_machine("technic_more_machines:hv_transmutator", {
    typename = "trasmutating",
    description = "HV Transmutator",
    tier = "HV",
    demand = {60000, 50000, 40000},
    speed = 0.5,
    upgrade = 1,
    tube = 1,
})
