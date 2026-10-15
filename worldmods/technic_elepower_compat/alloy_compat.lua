--Recipes for technic furnaces.
local technic_alloying = {
	{"default:copper_ingot 2",          "moreores:silver_ingot",          "basic_materials:brass_ingot 3"},
	{"default:gold_ingot 2",            "elepower_dynamics:invar_ingot",  "elepower_dynamics:electrum_ingot 3"},
	{"default:coal_lump",               "elepower_dynamics:coal_dust 4",  "elepower_dynamics:graphite_ingot"},
	{"default:obsidian_glass",          "elepower_dynamics:lead_ingot 4", "elepower_dynamics:hardened_glass 4", 8},
	{"default:bronze_ingot",            "default:steel_ingot 4",          "elepower_machines:heat_casing 4"},
	{"elepower_dynamics:iron_ingot 3",  "elepower_dynamics:nickel_ingot", "elepower_dynamics:invar_ingot 4"},
	{"elepower_dynamics:silicon_wafer", "elepower_dynamics:gold_dust 4",  "elepower_dynamics:silicon_wafer_doped", 8},
	{"basic_materials:silicon",         "elepower_dynamics:coal_dust 2",  "elepower_dynamics:silicon_wafer"},
}

for _, data in pairs(technic_alloying) do
	technic.register_alloy_recipe({input = {data[1], data[2]}, output = data[3], time = data[4]})
end

--Recipes for elepower furnaces.
local elepower_alloying = {
	{"technic:copper_dust 2",        "technic:zinc_dust",      "technic:brass_dust 3"},
	{"default:copper_ingot 2",       "technic:zinc_ingot",     "basic_materials:brass_ingot 3"},
	{"technic:copper_dust 7",        "technic:tin_dust",       "technic:bronze_dust 8", 8},
	{"default:ice",                  "bucket:bucket_empty",    "bucket:bucket_water", 1},
	{"technic:wrought_iron_dust 2",  "technic:coal_dust",      "technic:carbon_steel_dust 2"},
	{"technic:wrought_iron_ingot 2", "technic:coal_dust",      "technic:carbon_steel_ingot 2"},
	{"technic:carbon_steel_dust 2",  "technic:coal_dust",      "technic:cast_iron_dust 2"},
	{"technic:carbon_steel_ingot 2", "technic:coal_dust",      "technic:cast_iron_ingot 2"},
	{"technic:raw_latex 4",          "technic:coal_dust 2",    "technic:rubber 6", 1},
	{"default:sand 2",               "technic:coal_dust 2",    "technic:silicon_wafer"},
	{"technic:silicon_wafer",        "technic:gold_dust",      "technic:doped_silicon_wafer"},
	{"technic:carbon_steel_dust 4",  "technic:chromium_dust",  "technic:stainless_steel_dust 5", 5},
	{"technic:carbon_steel_ingot 4", "technic:chromium_ingot", "technic:stainless_steel_ingot 5", 5},
}

for _, data in pairs(elepower_alloying) do
	elepm.register_craft({type   = "alloy",	recipe = {data[1], data[2]}, output = data[3], time = data[4] or 4})
end

--Recipes for both technic and elepower alloy furnaces.
local register_alloy_recipes = {
	{"default:copper_ingot 2",          "elepower_dynamics:zinc_ingot",   "basic_materials:brass_ingot 3"},
	{"default:steel_ingot 2",           "elepower_dynamics:coal_dust",    "technic:carbon_steel_ingot 2"},
	{"technic:carbon_steel_dust 2",     "elepower_dynamics:coal_dust",    "technic:cast_iron_dust 2"},
	{"technic:carbon_steel_ingot 2",    "elepower_dynamics:coal_dust",    "technic:cast_iron_ingot 2"},
	{"default:coal_lump",               "technic:coal_dust 4",            "elepower_dynamics:graphite_ingot"},
	{"default:obsidian_glass",          "technic:lead_ingot 4",           "elepower_dynamics:hardened_glass 4", 7.5, 8},
	{"technic:cast_iron_ingot 3",       "elepower_dynamics:nickel_ingot", "elepower_dynamics:invar_ingot 4"},
	{"technic:raw_latex 4",             "elepower_dynamics:coal_dust 2",  "technic:rubber 6", 1, 1},
	{"default:desert_sand 2",           "technic:coal_dust 2",            "elepower_dynamics:silicon_wafer"},
	{"basic_materials:silicon",         "technic:coal_dust 2",            "elepower_dynamics:silicon_wafer"},
	{"technic:silicon_wafer",           "elepower_dynamics:gold_dust",    "technic:doped_silicon_wafer"},
	{"elepower_dynamics:silicon_wafer", "technic:gold_dust 4",            "elepower_dynamics:silicon_wafer_doped", 8},
	{"default:sand 2",                  "elepower_dynamics:coal_dust 2",  "technic:silicon_wafer"},
}

for _, data in pairs(register_alloy_recipes) do
	technic.register_alloy_recipe({input = {data[1], data[2]}, output = data[3], time = data[4] or 6})	
	elepm.register_craft({type = "alloy", recipe = {data[1], data[2]}, output = data[3], time = data[5] or 4})
end
