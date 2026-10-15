--register craft type
technic.register_recipe_type("distilling", {
	description = "Distilling",
	icon = "technic_more_machines_mv_distiller_front.png",
	input_size = 2,
})
--register recipes
function technic.register_distiller_recipe(data)
	data.time = data.time or 4
	technic.register_recipe("distilling", data)
end

local recipes = {
	{"farming:sugar 3", "vessels:glass_bottle", "farming:bottle_ethanol"},
	{"mobs:honey", "vessels:glass_bottle", "farming:bottle_ethanol"},
}

minetest.register_craft({
	output = 'technic_more_machines:mv_distiller',
	recipe = {
		{'technic:stainless_steel_ingot', 'basic_materials:heating_element',   'technic:stainless_steel_ingot'},
		{'pipeworks:tube_1',              'technic:mv_transformer', 'pipeworks:tube_1'},
		{'technic:stainless_steel_ingot', 'technic:mv_cable',       'technic:stainless_steel_ingot'},
	}
})

for _, data in pairs(recipes) do
	technic.register_distiller_recipe({input = {data[1], data[2]}, output = data[3]})
end
--register machine function
technic.register_base_machine("technic_more_machines:mv_distiller", {
	typename = "distilling",
	description = "MV Distiller",
	tier = "MV",
	demand = {800, 600, 400},
	speed = 2,
	upgrade = 1,
	tube = 1,
})