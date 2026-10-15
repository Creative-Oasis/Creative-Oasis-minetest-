minetest.register_craftitem("nyancats_plus:rainbow_shard", {
	description = "Rainbow shard",
	inventory_image = "rainbow_shard.png",
})
minetest.register_craft({
	output = 'nyancats_plus:rainbow_shard 9',
	recipe = {
		{"default:nyancat_rainbow"},
	}
})
minetest.register_tool("nyancats_plus:rainbow_pick",{
	description = "Rainbow Pickaxe",
	inventory_image = "rainbow_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=1.0, [2]=0.7, [3]=0.25}, uses=0},
		},
		damage_groups = {fleshy=6},
	},
})
minetest.register_tool("nyancats_plus:rainbow_shovel", {
	description = "Rainbow Shovel",
	inventory_image = "rainbow_shovel.png",
	wield_image = "rainbow_shovel.png^[transformR90",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=0.8, [2]=0.3, [3]=0.1}, uses=0, maxlevel=5},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("nyancats_plus:rainbow_axe", {
	description = "Rainbow Axe",
	inventory_image = "rainbow_axe.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=1.9, [2]=0.70, [3]=0.30}, uses=0, maxlevel=5},
		},
		damage_groups = {fleshy=8},
	},
})
minetest.register_tool("nyancats_plus:rainbow_sword", {
	description = "Rainbow Sword",
	inventory_image = "rainbow_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.6,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.70, [2]=0.70, [3]=0.10}, uses=0, maxlevel=5},
		},
		damage_groups = {fleshy=10},
	}
})
farming.register_hoe("nyancats_plus:rainbow_hoe", {
	description = "Rainbow Hoe",
	inventory_image = "rainbow_hoe.png",
	max_uses = 0,
	recipe = {
		{"nyancats_plus:rainbow_shard", "nyancats_plus:rainbow_shard"},
		{"", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "nyancats_plus:rainbow_pick",
	recipe = {
		{"nyancats_plus:rainbow_shard", "nyancats_plus:rainbow_shard", "nyancats_plus:rainbow_shard"},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})

minetest.register_craft({
	output = "nyancats_plus:rainbow_shovel",
	recipe = {
		{"", "nyancats_plus:rainbow_shard", ""},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})
minetest.register_craft({
	output = "nyancats_plus:rainbow_shovel",
	recipe = {
		{"", "nyancats_plus:rainbow_shard", ""},
		{'', 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})
minetest.register_craft({
	output = "nyancats_plus:rainbow_axe",
	recipe = {
		{"nyancats_plus:rainbow_shard", "nyancats_plus:rainbow_shard", ""},
		{"nyancats_plus:rainbow_shard", 'group:stick', ''},
		{'', 'group:stick', ''},
	}
})
minetest.register_craft({
	output = "nyancats_plus:rainbow_sword",
	recipe = {
		{"", "nyancats_plus:rainbow_shard", ""},
		{'', "nyancats_plus:rainbow_shard", ''},
		{'', 'group:stick', ''},
	}
})