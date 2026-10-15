--elepower recipes for technic grinders
local technic_grinding = {
	{"elepower_dynamics:brass_plate",      "technic:brass_dust"},
	{"basic_materials:brass_block",        "technic:brass_dust 9", 10},
	{"default:bronzeblock",	               "technic:bronze_dust 9", 10},
	{"elepower_dynamics:bronze_plate",     "technic:bronze_dust"},
	{"default:copperblock",      	       "technic:copper_dust 9", 10},
	{"elepower_dynamics:copper_plate",     "technic:copper_dust"},
	{"default:diamondblock",               "elepower_dynamics:diamond_dust 9", 10},
	{"elepower_dynamics:electrum_ingot",   "elepower_dynamics:electrum_dust"},
	{"elepower_dynamics:electrum_plate",   "elepower_dynamics:electrum_dust"},
	{"farming:wheat",                      "farming:flour 2"},
	{"default:goldblock",                  "technic:gold_dust 9", 10},
	{"elepower_dynamics:gold_plate",       "technic:gold_dust"},
	{"elepower_dynamics:graphite_ingot",   "elepower_dynamics:graphite_rod 3"},
	{"elepower_dynamics:invar_ingot",      "elepower_dynamics:invar_dust"},
	{"elepower_dynamics:invar_block",      "elepower_dynamics:invar_dust 9", 10},
	{"elepower_dynamics:invar_plate",      "elepower_dynamics:invar_dust"},
	{"elepower_dynamics:iron_ingot",       "elepower_dynamics:iron_dust"},
	{"elepower_dynamics:iron_plate",       "elepower_dynamics:iron_dust"},
	{"elepower_dynamics:lead_lump",	       "elepower_dynamics:lead_dust 2"},
	{"elepower_dynamics:lead_ingot",       "elepower_dynamics:lead_dust"},
	{"elepower_dynamics:lead_plate",       "technic:lead_dust"},
	{"default:mese",                       "default:mese_crystal 9", 10},
	{"default:mese_crystal",               "default:mese_crystal_fragment 9"},
	{"default:mese_crystal_fragment",      "elepower_dynamics:mese_dust", 1},
	{"moreores:mithril_block",             "technic:mithril_dust 9", 10},
	{"elepower_dynamics:mithril_plate",    "technic:mithril_dust"},
	{"elepower_dynamics:nickel_lump",      "elepower_dynamics:nickel_dust 2"},
	{"elepower_dynamics:nickel_ingot",     "elepower_dynamics:nickel_dust"},
	{"elepower_dynamics:nickel_block",     "elepower_dynamics:nickel_dust 9", 10},
	{"elepower_dynamics:nickel_plate",     "elepower_dynamics:nickel_dust"},
	{"moreores:silver_block",              "technic:silver_dust 9", 10},
	{"elepower_dynamics:silver_plate",     "technic:silver_dust"},
	{"default:tinblock",                   "technic:tin_dust 9", 10},
	{"elepower_dynamics:tin_plate",	       "technic:tin_dust"},
	{"elepower_dynamics:viridisium_lump",  "elepower_dynamics:viridisium_dust 2"},
	{"elepower_dynamics:viridisium_ingot", "elepower_dynamics:viridisium_dust"},
	{"elepower_dynamics:viridisium_block", "elepower_dynamics:viridisium_dust 9", 10},
	{"elepower_dynamics:viridisium_plate", "elepower_dynamics:viridisium_dust"},
	{"default:steelblock",	               "technic:wrought_iron_dust 9", 10},
	{"elepower_dynamics:steel_plate",      "technic:wrought_iron_dust"},
	{"elepower_dynamics:zinc_lump",	       "elepower_dynamics:zinc_dust 2"},
	{"elepower_dynamics:zinc_ingot",       "elepower_dynamics:zinc_dust"},
	{"elepower_dynamics:zinc_block",       "elepower_dynamics:zinc_dust 9", 10},
	{"elepower_dynamics:zinc_plate",       "technic:zinc_dust"},
}

for _, data in pairs(technic_grinding) do
	technic.register_grinder_recipe({input = {data[1]}, output = data[2], time = data[3] or 3})
end

--technic recipes for elepower grindstone and pulverizer. For grinding ore materials, time = output + 4. The default time is 8.
local elepower_grinding = {
	{"basic_materials:chain_brass 4",     "technic:brass_dust 3", 7},
	{"basic_materials:chainlink_brass 2", "technic:brass_dust"},
	{"technic:carbon_steel_ingot",        "technic:carbon_steel_dust"},
	{"technic:cast_iron_ingot",           "technic:cast_iron_dust"},
	{"technic:chernobylite_block",        "technic:chernobylite_dust"},
	{"technic:chromium_lump",             "technic:chromium_dust 2", 6},
	{"technic:chromium_ingot",            "technic:chromium_dust"},
	{"technic:carbon_plate",              "technic:coal_dust 12", 16},
	{"default:aspen_tree",                "technic:common_tree_grindings 4", 8},
	{"default:aspen_wood",                "technic:common_tree_grindings"},
	{"default:jungletree",                "technic:common_tree_grindings 4", 8},
	{"default:junglewood",                "technic:common_tree_grindings"},
	{"default:pine_tree",                 "technic:common_tree_grindings 4", 8},
	{"default:pine_wood",                 "technic:common_tree_grindings"},
	{"moretrees:rubber_tree_trunk_empty", "technic:common_tree_grindings 4", 8},
	{"basic_materials:copper_strip 6",    "technic:copper_dust"},
	{"technic:copper_plate",              "technic:copper_dust 5", 9},
	{"default:desert_stone",              "default:desert_sand"},
	{"default:desert_sandstone",          "default:desert_sand 2", 6},
	{"farming:seed_wheat",                "farming:flour 1", 4},
	{"default:cobble",                    "default:gravel"},
	{"technic:lead_lump",	              "technic:lead_dust 2", 6},
	{"technic:lead_ingot",	              "technic:lead_dust"},
	{"moretrees:rubber_tree_trunk",       "technic:rubber_tree_grindings 4", 8},
	{"default:gravel",                    "default:sand"},
	{"default:sandstone",                 "default:sand 2", 6},
	{"default:silver_sandstone",          "default:silver_sand 2", 6},
	{"technic:common_tree_grindings",     "technic:sawdust 4", 8},
	{"technic:rubber_tree_grindings",     "technic:sawdust 4", 8},
	{"default:ice",	                      "default:snowblock"},
	{"technic:stainless_steel_ingot",     "technic:stainless_steel_dust"},
	{"default:stone",                     "technic:stone_dust"},
	{"default:stone_block",               "technic:stone_dust"},
	{"default:stonebrick",                "technic:stone_dust"},
	{"default:silver_sand",               "technic:stone_dust"},
	{"technic:sulfur_lump",               "technic:sulfur_dust 2", 6},
	{"technic:uranium_lump",              "technic:uranium_dust 2", 6},
	{"technic:uranium_ingot",             "technic:uranium_dust"},
	{"technic:uranium0_ingot",            "technic:uranium0_dust"},
	{"technic:uranium35_ingot",           "technic:uranium35_dust"},
	{"xpanes:bar_flat 8",                 "technic:wrought_iron_dust 3", 7},
	{"basic_materials:chain_steel 4",     "technic:wrought_iron_dust 3", 7},
	{"basic_materials:chainlink_steel 2", "technic:wrought_iron_dust"},
	{"doors:door_steel",                  "technic:wrought_iron_dust 6", 10},
	{"pipeworks:pipe_1_empty 2",          "technic:wrought_iron_dust"},
	{"basic_materials:steel_bar 2",       "technic:wrought_iron_dust"},
	{"basic_materials:steel_strip 6",     "technic:wrought_iron_dust"},
	{"default:sign_wall_steel",           "technic:wrought_iron_dust 2", 6},
	{"doors:trapdoor_steel",              "technic:wrought_iron_dust 4", 8},
	{"technic:zinc_lump", 	              "technic:zinc_dust 2", 6},
	{"technic:zinc_ingot", 	              "technic:zinc_dust"},
}

if minetest.get_modpath("moretrees") then
	table.insert(elepower_grinding, {"moretrees:apple_tree_trunk",   "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:apple_tree_planks",  "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:beech_trunk",        "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:beech_planks",       "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:birch_trunk",        "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:birch_planks",       "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:cedar_trunk",        "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:cedar_planks",       "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:date_palm_trunk",    "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:date_palm_planks",   "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:fir_trunk",          "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:fir_planks",         "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:oak_trunk",          "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:oak_planks",         "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:palm_trunk",         "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:palm_planks",        "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:sequoia_trunk",      "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:sequoia_planks",     "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:spruce_trunk",       "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:spruce_planks",      "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:willow_trunk",       "technic:common_tree_grindings 4", 8})
	table.insert(elepower_grinding, {"moretrees:willow_planks",      "technic:common_tree_grindings"})
	table.insert(elepower_grinding, {"moretrees:rubber_tree_planks", "technic:rubber_tree_grindings"})
	if minetest.get_modpath("dye") then
		table.insert(elepower_grinding, {"default:acacia_tree", "technic:acacia_grindings 4", 8})
		table.insert(elepower_grinding, {"default:acacia_wood", "technic:acacia_grindings"})
	else
		table.insert(elepower_grinding, {"default:acacia_tree", "technic:common_tree_grindings 4", 8})
		table.insert(elepower_grinding, {"default:acacia_wood", "technic:common_tree_grindings"})
	end
end

for _,data in pairs(elepower_grinding) do
	elepm.register_craft({type = "grind", recipe = {data[1]}, output = data[2],	time = data[3] or 5})
end

--Recipes for both technic and elepower grinding machines.
local register_grinding_recipes = {
	{"technic:stainless_steel_block",   "technic:stainless_steel_dust 9"},
	{"technic:carbon_steel_block",      "technic:carbon_steel_dust 9"},
	{"technic:cast_iron_block",         "technic:cast_iron_dust 9"},
	{"technic:chromium_block",          "technic:chromium_dust 9"},
	{"elepower_dynamics:graphite_rod",  "elepower_dynamics:coal_dust 2", 6, 3},
	{"elepower_dynamics:diamond_plate", "elepower_dynamics:diamond_dust", 5, 3},
	{"technic:lead_block", 	            "technic:lead_dust 9"},
	{"technic:uranium_block",           "technic:uranium_dust 9"},
	{"technic:uranium0_block",          "technic:uranium0_dust 9"},
	{"technic:uranium35_block", 	    "technic:uranium35_dust 9"},
	{"technic:zinc_block", 	            "technic:zinc_dust 9"},
}

if minetest.get_modpath("elepower_nuclear") then
	table.insert(register_grinding_recipes, {"elepower_nuclear:nuclear_waste", "elepower_nuclear:depleted_uranium_dust 2", 6, 3})
	table.insert(register_grinding_recipes, {"elepower_nuclear:uranium_lump", "technic:uranium_dust 2", 6, 3})
end

for _, data in pairs(register_grinding_recipes) do
	elepm.register_craft({type = "grind", recipe = {data[1]}, output = data[2], time = data[3] or 13})
	technic.register_grinder_recipe({input = {data[1]}, output = data[2], time = data[4] or 10})
end
