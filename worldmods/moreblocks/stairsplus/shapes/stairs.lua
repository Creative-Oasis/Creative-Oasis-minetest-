stairsplus.api.register_shape("stair_half", {
	name_format = "stair_%s_half",
	description = "@1 Half Stair",
	shape_groups = { stair = 1, legacy = 1 },
	eighths = 3, -- 3/8 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0, 0, 0.5 },
			{ -0.5, 0, 0, 0, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair_right_half", {
	name_format = "stair_%s_right_half",
	description = "@1 Right Half Stair",
	shape_groups = { stair = 1, legacy = 1 },
	eighths = 3, -- 3/8 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 0, -0.5, -0.5, 0.5, 0, 0.5 },
			{ 0, 0, 0, 0.5, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair", {
	name_format = "stair_%s",
	description = "@1 Stair",
	groups = { morelights_supports_stairlight = 1 },
	shape_groups = { stair = 1, legacy = 1, stairs_legacy = 1 },
	eighths = 6, -- 3/4 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
			{ -0.5, 0, 0, 0.5, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair_inner", {
	name_format = "stair_%s_inner",
	aliases = { "stair_inner_%s" },
	description = "@1 Inner Stair",
	shape_groups = { stair = 1, legacy = 1, stairs_legacy = 1 },
	eighths = 7, -- 7/8 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
			{ -0.5, 0, 0, 0.5, 0.5, 0.5 },
			{ -0.5, 0, -0.5, 0, 0.5, 0 },
		},
	},
})

stairsplus.api.register_shape("stair_outer", {
	name_format = "stair_%s_outer",
	aliases = { "stair_outer_%s" },
	description = "@1 Outer Stair",
	shape_groups = { stair = 1, legacy = 1, stairs_legacy = 1 },
	eighths = 5, -- 5/8 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
			{ -0.5, 0, 0, 0, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair_alt_1", {
	name_format = "stair_%s_alt_1",
	description = "@1 1/16 Alt Stair",
	groups = { morelights_supports_stairlight = 1 },
	shape_groups = { stair = 1, legacy = 1 },
	eighths = 1, -- 1/16 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.0625, -0.5, 0.5, 0, 0 },
			{ -0.5, 0.4375, 0, 0.5, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair_alt_2", {
	name_format = "stair_%s_alt_2",
	description = "@1 1/8 Alt Stair",
	groups = { morelights_supports_stairlight = 1 },
	shape_groups = { stair = 1, legacy = 1 },
	eighths = 1, -- 1/8 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.125, -0.5, 0.5, 0, 0 },
			{ -0.5, 0.375, 0, 0.5, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair_alt_4", {
	name_format = "stair_%s_alt_4",
	description = "@1 1/4 Alt Stair",
	groups = { morelights_supports_stairlight = 1 },
	shape_groups = { stair = 1, legacy = 1 },
	eighths = 2, -- 1/4 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.25, -0.5, 0.5, 0, 0 },
			{ -0.5, 0.25, 0, 0.5, 0.5, 0.5 },
		},
	},
})

stairsplus.api.register_shape("stair_alt_8", {
	name_format = "stair_%s_alt_8",
	aliases = { "stair_%s_alt" },
	description = "@1 1/2 Alt Stair",
	groups = { morelights_supports_stairlight = 1 },
	shape_groups = { stair = 1, legacy = 1 },
	eighths = 4, -- 1/2 nodes
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0, 0 },
			{ -0.5, 0, 0, 0.5, 0.5, 0.5 },
		},
	},
})
