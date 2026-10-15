--
-- Even More Swords by AllenLim012
--

modpath=minetest.get_modpath("even_mosword")

dofile(modpath.."/flame_sword.lua")
dofile(modpath.."/frozen_sword.lua")
dofile(modpath.."/earth_sword.lua")
dofile(modpath.."/aqua_sword.lua")

--
-- Swords
--

minetest.register_tool("even_mosword:air_sword", {
	description = "Air Sword",
	inventory_image = "mosword_air_sword.png",
    light_source = 15,
	tool_capabilities = {
		full_punch_interval = 0.01,
		max_drop_level = 0,
		groupcaps = {
			snappy = {times={[1]=0.05, [2]=0.005, [3]=0.0005}, uses = 10000, maxlevel=1},
		},
		damage_groups = {fleshy=1000000, immortal=10000000},
	}
})

minetest.register_craft({
	output = 'even_mosword:air_sword',
	recipe = {
		{'', 'air'},
		{'', 'air'},
		{'', 'air'},
	}
})

minetest.register_tool("even_mosword:hero_sword", {
	description = "Sam's Sword",
	inventory_image = "mosword_hero_sword.png",
    light_source = 13,
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=150, maxlevel=5},
		},
		damage_groups = {fleshy=80},
	}
})

minetest.register_craft({
	output = 'even_mosword:hero_sword',
	recipe = {
		{'', 'even_mosword:hero_ingot', ''},
		{'', 'even_mosword:hero_ingot', ''},
		{'', 'default:steel_ingot', '',},
	}
})

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:matter_sword", {
	description = "Matter Sword",
	inventory_image = "mosword_matter_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=60, maxlevel=5},
		},
		damage_groups = {fleshy=8},
	}
})

minetest.register_craft({
	output = 'even_mosword:matter_sword',
	recipe = {
		{'', 'even_mosword:matter_ingot', ''},
		{'', 'even_mosword:matter_ingot', ''},
		{'', 'mosword:blacksteel_ingot', '',},
	}
})

end

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:black_sword", {
	description = "Black Sword",
	inventory_image = "mosword_black_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=80, maxlevel=5},
		},
		damage_groups = {fleshy=8},
	}
})

minetest.register_craft({
	output = 'even_mosword:black_sword',
	recipe = {
		{'', 'mosword:blacksteel_ingot'},
		{'', 'mosword:blacksteel_ingot'},
		{'', 'default:steel_ingot'},
	}
})

end

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:demon_blade", {
	description = "Demon Blade",
	inventory_image = "mosword_demon_blade.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=80, maxlevel=5},
		},
		damage_groups = {fleshy=13},
	}
})

minetest.register_craft({
	output = 'even_mosword:demon_blade',
	recipe = {
		{'bucket:bucket_lava', 'mosword:shadow_ingot', 'bucket:bucket_lava'},
		{'bucket:bucket_lava', 'mosword:shadow_ingot', 'bucket:bucket_lava'},
		{'', 'default:stick', '',},
	}
})

end

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:shadow_sword", {
	description = "Shadow Sword",
	inventory_image = "mosword_shadow_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=100, maxlevel=5},
		},
		damage_groups = {fleshy=20},
	}
})

minetest.register_craft({
	output = 'even_mosword:shadow_sword',
	recipe = {
		{'', 'even_mosword:shadow_blade'},
		{'', 'even_mosword:shadow_blade'},
		{'', 'default:copper_ingot'},
	}
})

end

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:cursed_sword", {
	description = "Herobrian's Sword",
	inventory_image = "mosword_cursed_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=100, maxlevel=5},
		},
		damage_groups = {fleshy=14},
	}
})

minetest.register_craft({
	output = 'even_mosword:cursed_sword',
	recipe = {
		{'default:obsidian_shard', 'mosword:blacksteel_ingot', 'default:obsidian_shard'},
		{'default:obsidian_shard', 'mosword:blacksteel_ingot', 'default:obsidian_shard'},
		{'', 'default:steel_ingot', '',},
	}
})

end

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:black_blade", {
	description = "Black Blade",
	inventory_image = "mosword_blacksteel_blade.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=90, maxlevel=5},
		},
		damage_groups = {fleshy=10},
	}
})

minetest.register_craft({
	output = 'even_mosword:black_blade',
	recipe = {
		{'', 'mosword:blacksteel_ingot', ''},
		{'mosword:blacksteel_ingot', 'default:gold_ingot', 'mosword:blacksteel_ingot'},
		{'', 'default:steel_ingot', '',},
	}
})

end

if minetest.get_modpath("mosword") then
-- add sword and recipe

minetest.register_tool("even_mosword:excalibur", {
	description = "Excalibur",
	inventory_image = "mosword_excalibur.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=100, maxlevel=5},
		},
		damage_groups = {fleshy=18},
	}
})

minetest.register_craft({
	output = 'even_mosword:excalibur',
	recipe = {
		{'', 'even_mosword:ex_ingot', ''},
		{'', 'even_mosword:ex_ingot', ''},
		{'', 'default:steel_ingot', '',},
	}
})

end

minetest.register_tool("even_mosword:glass_sword", {
	description = "Glass Sword",
	inventory_image = "mosword_glass_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=20, maxlevel=5},
		},
		damage_groups = {fleshy=10},
	}
})

minetest.register_craft({
	output = 'even_mosword:glass_sword',
	recipe = {
		{'', 'default:glass'},
		{'', 'default:glass'},
		{'', 'default:stick'},
	}
})

minetest.register_tool("even_mosword:nyan_sword", {
	description = "Nyan Sword",
	inventory_image = "mosword_nyan_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=10000, maxlevel=5},
		},
		damage_groups = {fleshy=30},
	}
})

minetest.register_craft({
	output = 'even_mosword:nyan_sword',
	recipe = {
		{'', 'even_mosword:nyan_ingot'},
		{'', 'even_mosword:nyan_ingot'},
		{'', 'even_mosword:nyan_ingot'},
	}
})

minetest.register_tool("even_mosword:golden_blade", {
	description = "Golden Blade",
	inventory_image = "mosword_golden_blade.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=70, maxlevel=5},
		},
		damage_groups = {fleshy=10},
	}
})

minetest.register_craft({
	output = 'even_mosword:golden_blade',
	recipe = {
		{'', 'default:gold_ingot', 'default:steel_ingot'},
		{'', 'default:gold_ingot', 'default:steel_ingot'},
		{'', 'mosword:blacksteel_ingot', '',},
	}
})

if minetest.get_modpath("bone") then
-- add sword and recipe

minetest.register_tool("even_mosword:skeletal_sword", {
	description = "Skeletal Sword",
	inventory_image = "mosword_skeletal_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=25, maxlevel=5},
		},
		damage_groups = {fleshy=11},
	}
})

minetest.register_craft({
	output = 'even_mosword:skeletal_sword',
	recipe = {
		{'', 'bone:bone'},
		{'', 'bone:bone'},
		{'', 'bone:bone'},
	}
})

end

minetest.register_tool("even_mosword:golden_sword", {
	description = "Ancient Golden Sword",
	inventory_image = "mosword_golden_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.6, [3]=0.40}, uses=100, maxlevel=5},
		},
		damage_groups = {fleshy=15},
	}
})

minetest.register_craft({
	output = 'even_mosword:golden_sword',
	recipe = {
		{'', 'even_mosword:golden_sword_blade'},
		{'', 'even_mosword:golden_sword_blade'},
		{'', 'default:gold_ingot'},
	}
})

--
-- Items
--

minetest.register_craftitem("even_mosword:nyan_ingot", {
	description = "Nyan Ingot",
	inventory_image = "mosword_nyan_ingot.png"
})

minetest.register_craft({
	type = "cooking",
	recipe = "default:nyancat_rainbow",
	output = "even_mosword:nyan_ingot",
})

minetest.register_craft({
	type = "fuel",
	recipe = "default:nyancat_rainbow",
	burntime = 5,
})

if minetest.get_modpath("mosword") then
-- add item

minetest.register_craftitem("even_mosword:shadow_blade", {
	description = "[Used for Crafting] Shadow Blade",
	inventory_image = "mosword_shadow_blade.png"
})

minetest.register_craft({
	output = 'even_mosword:shadow_blade',
	recipe = {
		{'', '', 'mosword:shadow_ingot'},
		{'', 'mosword:shadow_ingot', ''},
		{'mosword:shadow_ingot', '', ''},
	}
})

end

if minetest.get_modpath("mosword") then
-- add item

minetest.register_craftitem("even_mosword:ex_ingot", {
	description = "Ex Ingot",
	inventory_image = "mosword_ex_ingot.png"
})

minetest.register_craft({
	type = "cooking",
	recipe = "mosword:master_ingot",
	output = "even_mosword:ex_ingot",
})

minetest.register_craft({
	type = "fuel",
	recipe = "mosword:master_ingot",
	burntime = 10,
})

end

if minetest.get_modpath("mosword") then
-- add item

minetest.register_craftitem("even_mosword:matter_ingot", {
	description = "Matter Gold Ingot",
	inventory_image = "mosword_matter_ingot.png"
})

minetest.register_craft({
	output = 'even_mosword:matter_ingot 4',
	recipe = {
		{'', 'mosword:blacksteel_ingot', ''},
		{'mosword:blacksteel_ingot', 'default:gold_ingot', 'mosword:blacksteel_ingot'},
		{'', 'mosword:blacksteel_ingot', '',},
	}
})

minetest.register_craft({
	output = 'even_mosword:matter_ingot 9',
	recipe = {
		{'', '', ''},
		{'', 'even_mosword:matter_block', ''},
		{'', '', '',},
	}
})

end

minetest.register_craftitem("even_mosword:hero_ingot", {
	description = "Hero Ingot",
	inventory_image = "mosword_hero_ingot.png"
})

minetest.register_craft({
	output = "even_mosword:hero_ingot",
	recipe = {
		{"tac_nayn:tacnayn_rainbow", "armor_addon:waffleblock", "pbj_pup:nyancat_rainbow"},
		{"default:diamond", "scifi_nodes:egg", "default:diamond"},
		{"ethereal:crystal_ingot", "alien_material:alien_ingot", "lavastuff:ingot"},
	}
})


minetest.register_craft({
	type = "fuel",
	recipe = "default:mese",
	burntime = 10,
})

minetest.register_craft({
	output = 'even_mosword:hero_ingot 9',
	recipe = {
		{'', '', ''},
		{'', 'even_mosword:hero_mese', ''},
		{'', '', '',},
	}
})

minetest.register_craftitem("even_mosword:golden_sword_blade", {
	description = "[Used for Crafting] Golden Sword Blade",
	inventory_image = "mosword_golden_sword_blade.png"
})

minetest.register_craft({
	output = 'even_mosword:golden_sword_blade',
	recipe = {
		{'', '', 'default:gold_ingot'},
		{'', 'default:gold_ingot', ''},
		{'default:gold_ingot', '', ''},
	}
})

--
-- Blocks
--

if minetest.get_modpath("mosword") then
-- add node and recipe

minetest.register_node("even_mosword:matter_block", {
	description = "Matter Gold Block",
	tiles = {"mosword_matter_block.png"},
	groups = {cracky=3},
	paramtype="light",
})

minetest.register_craft({
	output = 'even_mosword:matter_block',
	recipe = {
		{'even_mosword:matter_ingot', 'even_mosword:matter_ingot', 'even_mosword:matter_ingot'},
		{'even_mosword:matter_ingot', 'even_mosword:matter_ingot', 'even_mosword:matter_ingot'},
		{'even_mosword:matter_ingot', 'even_mosword:matter_ingot', 'even_mosword:matter_ingot',},
	}
})

end

minetest.register_node("even_mosword:hero_mese", {
	description = "Hero Mese Block",
	tiles = {"mosword_hero_mese.png"},
	groups = {cracky=3},
	paramtype="light",
})

minetest.register_craft({
	output = 'even_mosword:hero_mese',
	recipe = {
		{'even_mosword:hero_ingot', 'even_mosword:hero_ingot', 'even_mosword:hero_ingot'},
		{'even_mosword:hero_ingot', 'even_mosword:hero_ingot', 'even_mosword:hero_ingot'},
		{'even_mosword:hero_ingot', 'even_mosword:hero_ingot', 'even_mosword:hero_ingot',},
	}
})