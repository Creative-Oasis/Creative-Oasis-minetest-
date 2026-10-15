-- MV distiller
local S = technic.getter

minetest.register_craft({
	output = 'technic_more_machines:mv_distiller',
	recipe = {
		{'technic:stainless_steel_ingot', 'basic_materials:heating_element',   'technic:stainless_steel_ingot'},
		{'pipeworks:tube_1',              'technic:mv_transformer', 'pipeworks:tube_1'},
		{'technic:stainless_steel_ingot', 'technic:mv_cable',       'technic:stainless_steel_ingot'},
	}
})
--register craft type
technic.register_recipe_type("distilling", {
	description = S("Distilling"),
	input_size = 2,
	icon = "technic_more_machines_mv_distiller_front.png",
})

function technic.register_distiller(data)
	data.typename = "distilling"
	data.machine_name = "distiller"
	data.machine_desc = technic.getter("%s Distiller")
	technic.register_base_machine(data)
end

technic.register_distiller({tier = "MV", demand = {800, 600, 400}, speed = 2, upgrade = 1, tube = 1})

function technic.register_distiller_recipe(data)
	data.time = data.time or 4
	technic.register_recipe("distilling", data)
end

local recipes = {
	{"farming:sugar 3", "vessels:glass_bottle", "farming:bottle_ethanol"},
	{"mobs:honey", "vessels:glass_bottle", "farming:bottle_ethanol"},
}

for _, data in pairs(recipes) do
	technic.register_distiller_recipe({input = {data[1], data[2]}, output = data[3]})
end
