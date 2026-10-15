--Recipes for technic compressors
local technic_compress = {
	{"basic_materials:brass_ingot",          "elepower_dynamics:brass_plate"},
	{"default:bronze_ingot",                 "elepower_dynamics:bronze_plate"},
	{"elepower_dynamics:coal_dust 4",        "elepower_dynamics:carbon_fiber"},
	{"elepower_dynamics:carbon_sheet",       "technic:carbon_plate", 4},
	{"elepower_dynamics:carbon_fiber 4",     "elepower_dynamics:carbon_sheet"},
	--{"default:copper_ingot",                 "elepower_dynamics:copper_plate"},
	{"elepower_dynamics:diamond_dust",       "default:diamond"},
	{"default:diamond",                      "elepower_dynamics:diamond_plate"},
	{"elepower_dynamics:electrum_ingot",     "elepower_dynamics:electrum_plate"},
	{"default:gold_ingot",                   "elepower_dynamics:gold_plate"},
	{"elepower_dynamics:invar_ingot",        "elepower_dynamics:invar_plate"},
	{"technic:cast_iron_ingot",              "elepower_dynamics:iron_plate"},
	{"elepower_dynamics:iron_ingot",         "elepower_dynamics:iron_plate"},
	{"technic:lead_ingot",                   "elepower_dynamics:lead_plate"},
	{"elepower_dynamics:lead_ingot",         "elepower_dynamics:lead_plate"},
	{"default:mese_crystal 9",               "default:mese", 4},
	{"default:mese_crystal_fragment 9",      "default:mese_crystal"},
	{"elepower_dynamics:mese_dust",          "default:mese_crystal_fragment", 1},
	{"moreores:mithril_ingot",               "elepower_dynamics:mithril_plate"},
	{"elepower_dynamics:nickel_ingot",       "elepower_dynamics:nickel_plate"},
	{"moreores:silver_ingot",                "elepower_dynamics:silver_plate"},
	{"default:steel_ingot",                  "elepower_dynamics:steel_plate"},
	{"default:tin_ingot",                    "elepower_dynamics:tin_plate"},
	{"elepower_dynamics:viridisium_ingot",   "elepower_dynamics:viridisium_plate"},
	{"elepower_dynamics:viridisium_block 8", "elepower_dynamics:xycrone_lump", 20},
	{"technic:zinc_ingot",                   "elepower_dynamics:zinc_plate"},
	{"elepower_dynamics:zinc_ingot",         "elepower_dynamics:zinc_plate"},
}

for _, data in pairs(technic_compress) do
	technic.register_compressor_recipe({input = {data[1]}, output = data[2], time = data[3] or 3})
end

--Recipes for elepower compressors
local elepower_compress = {
	{"technic:carbon_cloth",           "technic:carbon_plate 2", 6},
	{"elepower_dynamics:carbon_sheet", "technic:carbon_plate 2", 6},
	{"technic:mixed_metal_ingot",      "technic:composite_plate 2", 6},
	{"default:desert_sand 2",          "default:desert_sandstone 2", 1},
	{"technic:coal_dust 2",            "technic:graphite"},
	{"default:snowblock",              "default:ice 2"},
	{"technic:cast_iron_ingot",        "elepower_dynamics:iron_plate 2"},
	{"technic:lead_ingot",             "elepower_dynamics:lead_plate 2"},
	{"default:sand 2",                 "default:sandstone 2", 1},
	{"default:silver_sand 2",          "default:silver_sandstone 2", 1},
	{"technic:uranium35_ingot 5",      "technic:uranium_fuel 2", 6},
	{"technic:sawdust 2",              "default:wood"},
	{"elepower_dynamics:wood_dust 2",  "default:wood"},
	{"technic:zinc_ingot",             "elepower_dynamics:zinc_plate 2"},
}

for _, data in pairs(elepower_compress) do
	elepm.register_craft({type = "compress", recipe = {data[1], data[1]}, output = data[2], time = data[3] or 4})
end
