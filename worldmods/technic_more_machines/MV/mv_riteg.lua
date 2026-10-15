technic.register_machine("MV", "technic_more_machines:mv_riteg", technic.producer)
technic.register_machine("MV", "technic_more_machines:mv_riteg_2", technic.producer)
technic.register_machine("MV", "technic_more_machines:mv_riteg_3", technic.producer)
technic.register_machine("MV", "technic_more_machines:mv_riteg_4", technic.producer)
technic.register_machine("MV", "technic_more_machines:mv_riteg_5", technic.producer)

minetest.register_craft({
	output = 'technic_more_machines:mv_riteg',
	recipe = {
		{'pipeworks:pipe_1_empty', 'technic:geothermal', 'pipeworks:pipe_1_empty'},
		{'technic:uranium0_block', 'technic:uranium_fuel', 'technic:uranium0_block'},
		{'technic:chromium_block', 'technic:mv_cable', 'technic:chromium_block'},
	}
})

minetest.register_node("technic_more_machines:mv_riteg", {
	description = "MV Radioisotope Thermoelectric Generator\n"..minetest.colorize("#84bac1ff", "RADIOACTIVE, generates less power over time"),
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		{name="technic_more_machines_mv_riteg_front.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.00},},
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_riteg_side.png",
		"technic_more_machines_mv_riteg_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox1
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox2
			{0.3125, -0.5, -0.5, 0.375, 0.5, 0.5}, -- NodeBox3
			{0.1875, -0.5, -0.5, 0.25, 0.5, 0.5}, -- NodeBox4
			{0.0625, -0.5, -0.5, 0.125, 0.5, 0.5}, -- NodeBox5
			{-0.0625, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox6
			{-0.1875, -0.5, -0.5, -0.125, 0.5, 0.5}, -- NodeBox7
			{-0.3125, -0.5, -0.5, -0.25, 0.5, 0.5}, -- NodeBox8
			{-0.4375, -0.5, -0.5, -0.375, 0.5, 0.5}, -- NodeBox9
		}
	},
	groups = {cracky = 2, technic_machine = 1, technic_mv = 1, radioactive = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left"},
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("MV_EU_supply", 900)
			local timer = minetest.get_node_timer(pos)
        	timer:start(157788)
	end,
	on_timer = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_int("MV_EU_supply", meta:get_int("MV_EU_supply") - 1)
		if meta:get_int("MV_EU_supply") == 700 then
			technic.swap_node(pos, "technic_more_machines:mv_riteg_2")
		end
		return true
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Radioisotope Thermoelectric Generator - "..meta:get_int("MV_EU_supply").."EU")
	end,
})

minetest.register_node("technic_more_machines:mv_riteg_2", {
	description = "MV Radioisotope Thermoelectric Generator",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		{name="technic_more_machines_mv_riteg_front_2.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.00},},
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_riteg_side.png",
		"technic_more_machines_mv_riteg_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox1
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox2
			{0.3125, -0.5, -0.5, 0.375, 0.5, 0.5}, -- NodeBox3
			{0.1875, -0.5, -0.5, 0.25, 0.5, 0.5}, -- NodeBox4
			{0.0625, -0.5, -0.5, 0.125, 0.5, 0.5}, -- NodeBox5
			{-0.0625, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox6
			{-0.1875, -0.5, -0.5, -0.125, 0.5, 0.5}, -- NodeBox7
			{-0.3125, -0.5, -0.5, -0.25, 0.5, 0.5}, -- NodeBox8
			{-0.4375, -0.5, -0.5, -0.375, 0.5, 0.5}, -- NodeBox9
		}
	},
	groups = {cracky = 2, technic_machine = 1, technic_mv = 1, radioactive = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left"},
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("MV_EU_supply", 700)
			local timer = minetest.get_node_timer(pos)
        	timer:start(157788)
	end,
	on_timer = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_int("MV_EU_supply", meta:get_int("MV_EU_supply") - 1)
		if meta:get_int("MV_EU_supply") == 500 then
			technic.swap_node(pos, "technic_more_machines:mv_riteg_3")
		end
		return true
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Radioisotope Thermoelectric Generator - "..meta:get_int("MV_EU_supply").."EU")
	end,
})

minetest.register_node("technic_more_machines:mv_riteg_3", {
	description = "MV Radioisotope Thermoelectric Generator",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		{name="technic_more_machines_mv_riteg_front_3.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.00},},
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_riteg_side.png",
		"technic_more_machines_mv_riteg_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox1
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox2
			{0.3125, -0.5, -0.5, 0.375, 0.5, 0.5}, -- NodeBox3
			{0.1875, -0.5, -0.5, 0.25, 0.5, 0.5}, -- NodeBox4
			{0.0625, -0.5, -0.5, 0.125, 0.5, 0.5}, -- NodeBox5
			{-0.0625, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox6
			{-0.1875, -0.5, -0.5, -0.125, 0.5, 0.5}, -- NodeBox7
			{-0.3125, -0.5, -0.5, -0.25, 0.5, 0.5}, -- NodeBox8
			{-0.4375, -0.5, -0.5, -0.375, 0.5, 0.5}, -- NodeBox9
		}
	},
	groups = {cracky = 2, technic_machine = 1, technic_mv = 1, radioactive = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left"},
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("MV_EU_supply", 500)
			local timer = minetest.get_node_timer(pos)
        	timer:start(157788)
	end,
	on_timer = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_int("MV_EU_supply", meta:get_int("MV_EU_supply") - 1)
		if meta:get_int("MV_EU_supply") == 300 then
			technic.swap_node(pos, "technic_more_machines:mv_riteg_4")
		end
		return true
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Radioisotope Thermoelectric Generator - "..meta:get_int("MV_EU_supply").."EU")
	end,
})

minetest.register_node("technic_more_machines:mv_riteg_4", {
	description = "MV Radioisotope Thermoelectric Generator",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		{name="technic_more_machines_mv_riteg_front_4.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.00},},
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_riteg_side.png",
		"technic_more_machines_mv_riteg_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox1
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox2
			{0.3125, -0.5, -0.5, 0.375, 0.5, 0.5}, -- NodeBox3
			{0.1875, -0.5, -0.5, 0.25, 0.5, 0.5}, -- NodeBox4
			{0.0625, -0.5, -0.5, 0.125, 0.5, 0.5}, -- NodeBox5
			{-0.0625, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox6
			{-0.1875, -0.5, -0.5, -0.125, 0.5, 0.5}, -- NodeBox7
			{-0.3125, -0.5, -0.5, -0.25, 0.5, 0.5}, -- NodeBox8
			{-0.4375, -0.5, -0.5, -0.375, 0.5, 0.5}, -- NodeBox9
		}
	},
	groups = {cracky = 2, technic_machine = 1, technic_mv = 1, radioactive = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left"},
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("MV_EU_supply", 300)
			local timer = minetest.get_node_timer(pos)
        	timer:start(157788)
	end,
	on_timer = function(pos, node)
		local meta = minetest.get_meta(pos)
		meta:set_int("MV_EU_supply", meta:get_int("MV_EU_supply") - 1)
		if meta:get_int("MV_EU_supply") == 100 then
			technic.swap_node(pos, "technic_more_machines:mv_riteg_5")
			return false
		end
		return true
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Radioisotope Thermoelectric Generator - "..meta:get_int("MV_EU_supply").."EU")
	end,
})

minetest.register_node("technic_more_machines:mv_riteg_5", {
	description = "MV Radioisotope Thermoelectric Generator",
	tiles = {
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_distiller_bottom.png",
		{name="technic_more_machines_mv_riteg_front_5.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=2.00},},
		"technic_more_machines_mv_distiller_bottom.png",
		"technic_more_machines_mv_riteg_side.png",
		"technic_more_machines_mv_riteg_side.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.4375}, -- NodeBox1
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox2
			{0.3125, -0.5, -0.5, 0.375, 0.5, 0.5}, -- NodeBox3
			{0.1875, -0.5, -0.5, 0.25, 0.5, 0.5}, -- NodeBox4
			{0.0625, -0.5, -0.5, 0.125, 0.5, 0.5}, -- NodeBox5
			{-0.0625, -0.5, -0.5, 0, 0.5, 0.5}, -- NodeBox6
			{-0.1875, -0.5, -0.5, -0.125, 0.5, 0.5}, -- NodeBox7
			{-0.3125, -0.5, -0.5, -0.25, 0.5, 0.5}, -- NodeBox8
			{-0.4375, -0.5, -0.5, -0.375, 0.5, 0.5}, -- NodeBox9
		}
	},
	groups = {cracky = 2, technic_machine = 1, technic_mv = 1, radioactive = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left"},
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("MV_EU_supply", 100)
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "MV Radioisotope Thermoelectric Generator - "..meta:get_int("MV_EU_supply").."EU")
	end,
})
