-- HV transmutator
local S = technic.getter

technic.register_recipe_type("transmutating", {
	description = S("transmutating"),
	input_size = 1,
	icon = "technic_more_machines_hv_transmutator_front_active.png"
})

function technic.register_transmutator_recipe(data)
	data.time = data.time or 4
	technic.register_recipe("transmutating", data)
	
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
	technic.register_transmutator_recipe({input = { data[1] }, output = { data[2] } })
end

minetest.register_craft({
	output = 'technic_more_machines:hv_transmutator',
	recipe = {
		{'technic:stainless_steel_block', 'technic:power_monitor',   'technic:stainless_steel_block'},
		{'technic:hv_transformer', 'technic:mv_centrifuge', 'technic:hv_transformer'},
		{'technic:lead_block', 'technic:hv_cable', 'technic:lead_block'},
	}
})

function technic.register_transmutator(data)
	data.typename = "transmutating"
	data.machine_name = "transmutator"
	data.machine_desc = technic.getter("%s Transmutator")
	technic.register_base_machine(data)
end

technic.register_transmutator({tier = "HV", demand = {60000, 50000, 40000}, speed = 0.5, upgrade = 1, tube = 1, modname="technic_more_machines"})

minetest.register_alias_force('technic:hv_transmutator', 'technic_more_machines:hv_transmutator')
