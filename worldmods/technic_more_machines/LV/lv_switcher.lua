technic.register_cable_tier(":technic:lv_switcher", "LV")

minetest.register_node(":technic:lv_switcher", {
	description = "LV Swither",
	tiles = {
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",		
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_switcher.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, snappy=2, choppy=2, technic_lv_cable = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left", "right", "back"},
	connects_to = {"group:technic_lv_cable", "group:technic_lv"},
--[[	on_construct = function(pos)
		table.insert(network.all_nodes,pos)
	end,
	on_destruct = function(pos)
		technic.cables[pos] = nil
	end,]]
	on_construct = clear_networks,
	on_destruct = clear_networks,
})

minetest.register_node(":technic:lv_switcher_off", {
	description = "LV Swither OFF",
	tiles = {
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",		
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_switcher.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, technic_machine = 1, technic_lv = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left", "right", "back"},
	drop = "technic_more_machines:lv_switcher",
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "LV Switcher OFF")
	end,
})

minetest.register_craft({
	output = ':technic:lv_swither',
	recipe = {
		{'default:paper',        'default:paper',        'default:paper'},
		{'default:copper_ingot', 'default:copper_ingot', 'default:copper_ingot'},
		{'default:paper',        'default:paper',        'default:paper'},
	}
})

--technic.register_cable(":technic:lv_switcher", 1)
