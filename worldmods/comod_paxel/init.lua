-- comod_paxel: Diamond Paxel
-- Author: You
-- Custom durable paxel: damage 7, slightly faster than diamond, 200 uses

minetest.register_tool("comod_paxel:paxel_diamond", {
	description = "Diamond Paxel",
	inventory_image = "paxel_diamond.png",
	light_source = 10,
	tool_capabilities = {
		full_punch_interval = 0.8,  -- faster than diamond (0.9)
		max_drop_level = 3,

		groupcaps = {
			-- Pick
			cracky = {
				times = {[1]=1.8, [2]=0.9, [3]=0.45},  -- faster than diamond
				uses = 200,  -- very durable
				maxlevel = 3,
			},
			-- Axe
			choppy = {
				times = {[1]=1.8, [2]=0.9, [3]=0.45},
				uses = 200,
				maxlevel = 3,
			},
			-- Shovel
			crumbly = {
				times = {[1]=1.0, [2]=0.5, [3]=0.25},
				uses = 200,
				maxlevel = 3,
			},
		},

		damage_groups = { fleshy = 7 },  -- stronger than diamond pick
	},

	groups = { pickaxe = 1, axe = 1, shovel = 1 },
	sound = { breaks = "default_tool_breaks" },
})

-- Crafting recipe
-- [ Diamond Pick ][ Diamond Axe ][ Diamond Shovel ]
-- [              ][ Diamond     ][                ]
-- [              ][ Diamond     ][                ]

minetest.register_craft({
	output = "comod_paxel:paxel_diamond",
	recipe = {
		{"default:pick_diamond", "default:axe_diamond", "default:shovel_diamond"},
		{"", "default:diamond", ""},
		{"", "default:diamond", ""},
	},
})
