-- Load support for MT game translation.
local S = minetest.get_translator("mtc_chisel")

-- Brick 1
minetest.register_node("mtc_chisel:brick_1", {
	description = S("Brick Block (Chaotic Bricks)"),
	paramtype2 = "facedir",
	place_param2 = 0,
	tiles = {
		"mtc_chisel_brick_1.png^[transformFX",
		"mtc_chisel_brick_1.png",
	},
	is_ground_content = false,
	groups = {chisel_brick=1,cracky = 3},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_craft({
	output = "mtc_chisel:brick_1 4",
	recipe = {
        {"","","default:brick"},
		{"default:brick","mtc_chisel:chisel",""},
		{"","default:brick","default:brick"},
	},
	replacements = {{"mtc_chisel:chisel", "mtc_chisel:chisel"}},
})

-- Back to default
minetest.register_craft({
	type = "shapeless",
	output = "default:brick",
	recipe = {"mtc_chisel:chisel","group:chisel_brick"},
	replacements = {{"mtc_chisel:chisel", "mtc_chisel:chisel"}},
})
