minetest.register_tool("nanotech:carbon_pick", {
	description = "Carbon Composite Pickaxe",
	inventory_image = "carbon_pick.png",
    light_source = 12,
	wield_image = "carbon_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})

minetest.register_tool("nanotech:carbon_shovel", {
	description = "Carbon Composite Shovel",
	inventory_image = "carbon_shovel.png",
    light_source = 12,
	wield_image = "carbon_shovel.png",
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level=1,
		groupcaps={
			crumbly = {times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
})

minetest.register_tool("nanotech:carbon_axe", {
	description = "Carbon Composite Axe",
	inventory_image = "carbon_axe.png",
	wield_image = "carbon_axe.png",
    light_source = 12,
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
})

minetest.register_tool("nanotech:carbon_sword", {
	description = "Carbon Composite Sword",
	inventory_image = "carbon_sword.png",
    wield_image = "carbon_sword.png",
    light_source = 12,
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		},
		damage_groups = {fleshy=12},
	}
})

minetest.register_tool("nanotech:carbon_paxel", {
	description = "Carbon Composite Paxel",
	inventory_image = "carbon_paxel.png",
	wield_image = "carbon_paxel.png",
	light_source = 12,
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		    crumbly = {times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		    choppy = {times={[1]=0.1, [2]=0.1, [3]=0.1}, uses=500, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
})