minetest.register_node("technic_more_machines:sign_keepout", {
	description = "Keep Out",
	drawtype = "signlike",
	walkable = false,
	tiles = {"sign_keepout.png"},
	wield_image =  "sign_keepout.png",
	inventory_image =  "sign_keepout.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	visual_scale = 2,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2},
});

minetest.register_node("technic_more_machines:sign_danger", {
	description = "Danger",
	drawtype = "signlike",
	walkable = false,
	tiles = {"sign_danger.png"},
	wield_image =  "sign_danger.png",
	inventory_image =  "sign_danger.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2},
});

minetest.register_node("technic_more_machines:sign_biohazard", {
	description = "Biohazard",
	drawtype = "signlike",
	walkable = false,
	tiles = {"sign_biohazard.png"},
	wield_image =  "sign_biohazard.png",
	inventory_image =  "sign_biohazard.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	visual_scale = 2,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2},
});

minetest.register_node("technic_more_machines:sign_warning", {
	description = "Warning",
	drawtype = "signlike",
	walkable = false,
	tiles = {"sign_warning.png"},
	wield_image =  "sign_warning.png",
	inventory_image =  "sign_warning.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 2},
});

minetest.register_craft({
	output = "technic_more_machines:sign_keepout",
	recipe = {
	{"dye:yellow", "dye:black", "dye:red"},
	{"", "default:sign_wall_steel", ""},
	{"", "", ""}
  }
})

minetest.register_craft({
	output = "technic_more_machines:sign_danger",
	recipe = {
	{"dye:red", "dye:black", "dye:yellow"},
	{"", "default:sign_wall_steel", ""},
	{"", "", ""}
  }
})

minetest.register_craft({
	output = "technic_more_machines:sign_biohazard",
	recipe = {
	{"dye:red", "dye:black", "dye:red"},
	{"", "default:sign_wall_steel", ""},
	{"", "", ""}
  }
})

minetest.register_craft({
	output = "technic_more_machines:sign_warning",
	recipe = {
	{"dye:yellow", "dye:black", "dye:black"},
	{"", "default:sign_wall_steel", ""},
	{"", "", ""}
  }
})
