minetest.register_node("technic_more_machines:lv_rat_wheel", {
	description = "LV Rat Wheel Generator",
	tiles = {
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",
		"technic_more_machines_lv_rat_wheel_side.png",		
		{name="technic_more_machines_lv_rat_wheel.png^[transformFX", animation={type="vertical_frames", aspect_w=18, aspect_h=18, length=1.00},},
		{name="technic_more_machines_lv_rat_wheel.png", animation={type="vertical_frames", aspect_w=18, aspect_h=18, length=1.00},},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, technic_machine = 1, technic_lv = 1},
	sounds = default.node_sound_metal_defaults(),
	connect_sides = {"top", "bottom", "left", "right"},
	on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("LV_EU_supply", 100)
	end,
	technic_run = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "LV Rat Wheel Generator - "..meta:get_int("LV_EU_supply").."EU")
	end,
})

technic.register_machine("LV", "technic_more_machines:lv_rat_wheel", technic.producer)

minetest.register_craft({
	output = "technic_more_machines:lv_rat_wheel",
	recipe = {
	{"default:steel_ingot", "basic_materials:gear_steel", "default:steel_ingot"},
	{"basic_materials:gear_steel", "mobs_animal:rat", "basic_materials:gear_steel"},
	{"basic_materials:silver_wire", "technic:lv_transformer", "technic:lv_cable"}
  }
})
