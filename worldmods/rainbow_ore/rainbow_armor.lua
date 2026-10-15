
local S = minetest.get_translator(rainbow_ore.modname)


--Define Rainbow Armor
minetest.register_tool("rainbow_ore:rainbow_ore_helmet", {
	description = S("Rainbow Helmet"),
	inventory_image = "rainbow_ore_helmet_inv.png",
	groups = {armor_head=8, armor_heal=10, armor_use=400},
	wear = 0,
})
minetest.register_tool("rainbow_ore:rainbow_ore_chestplate", {
	description = S("Rainbow Chestplate"),
	inventory_image = "rainbow_ore_chestplate_inv.png",
	groups = {armor_torso=11, armor_heal=10, armor_use=400},
	wear = 0,
})
minetest.register_tool("rainbow_ore:rainbow_ore_leggings", {
	description = S("Rainbow Leggings"),
	inventory_image = "rainbow_ore_leggings_inv.png",
	groups = {armor_legs=10, armor_heal=10, armor_use=400},
	wear = 0,
})
minetest.register_tool("rainbow_ore:rainbow_ore_boots", {
	description = S("Rainbow Boots"),
	inventory_image = "rainbow_ore_boots_inv.png",
	groups = {armor_feet=7, armor_heal=9, armor_use=400},
	wear = 0,
})
 
 
--Define Rainbow Armor crafting recipe
minetest.register_craft({
	output = "rainbow_ore:rainbow_ore_helmet",
	recipe = {
		{"rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot"},
		{"rainbow_ore:rainbow_ore_ingot", "", "rainbow_ore:rainbow_ore_ingot"},
		{"", "", ""},
	},
})
minetest.register_craft({
	output = "rainbow_ore:rainbow_ore_chestplate",
	recipe = {
		{"rainbow_ore:rainbow_ore_ingot", "", "rainbow_ore:rainbow_ore_ingot"},
		{"rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot"},
		{"rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot"},
	},
})
minetest.register_craft({
	output = "rainbow_ore:rainbow_ore_leggings",
	recipe = {
		{"rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot", "rainbow_ore:rainbow_ore_ingot"},
		{"rainbow_ore:rainbow_ore_ingot", "", "rainbow_ore:rainbow_ore_ingot"},
		{"rainbow_ore:rainbow_ore_ingot", "", "rainbow_ore:rainbow_ore_ingot"},
	},
})
minetest.register_craft({
	output = "rainbow_ore:rainbow_ore_boots",
	recipe = {
		{"rainbow_ore:rainbow_ore_ingot", "", "rainbow_ore:rainbow_ore_ingot"},
		{"rainbow_ore:rainbow_ore_ingot", "", "rainbow_ore:rainbow_ore_ingot"},
	},
})