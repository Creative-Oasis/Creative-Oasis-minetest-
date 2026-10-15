--Recipe registration
local recipes = {
	{type = "shapeless", output = "elepower_dynamics:acidic_compound", recipe = {
			"technic:copper_dust", "technic:copper_dust", "technic:copper_dust", "technic:copper_dust", "farming:seed_wheat"
		}
	},
	{output = "elepower_dynamics:battery 2", recipe = {
			{"group:zinc_dust", "elepower_dynamics:graphite_rod", "group:lead_dust"},
			{"elepower_dynamics:tin_plate", "default:mese_crystal_fragment", "elepower_dynamics:tin_plate"},
			{"elepower_dynamics:tin_plate", "default:mese_crystal_fragment", "elepower_dynamics:tin_plate"},
		}
	},
	{output = "technic:battery", recipe = {
			{"group:wood", "group:sulfur", "group:wood"},
			{"group:lead_ingot", "group:water_bucket", "group:lead_ingot"},
			{"group:wood", "group:sulfur", "group:wood"},
		},
		replacements = {
			{"group:water_bucket", "bucket:bucket_empty"},
		}
	},
	{output = "technic:battery", recipe = {
			{"group:wood", "group:sulfur", "group:wood"},
			{"group:lead_ingot", "basic_materials:oil_extract", "group:lead_ingot"},
			{"group:wood", "group:sulfur", "group:wood"},
		}
	},
	{output = "technic:battery", recipe = {
			{"group:wood", "default:copper_ingot", "group:wood"},
			{"group:wood", "default:tin_ingot", "group:wood"},
			{"group:wood", "default:copper_ingot", "group:wood"},
		}
	},
	{type = "cooking", output = "basic_materials:brass_ingot", recipe = "elepower_dynamics:brass_dust"},
	{type = "cooking", output = "default:bronze_ingot", recipe = "elepower_dynamics:bronze_dust"},
	{output = "bucket:bucket_empty", recipe = {
			{"technic:cast_iron_ingot", "", "technic:cast_iron_ingot"},
			{"", "technic:cast_iron_ingot", ""},
		}
	},
	{type = "fuel",	recipe = "group:coal_dust",	time = 50},
	{output = "elepower_dynamics:conduit 8", recipe = {
			{"technic:lead_ingot", "technic:lead_ingot", "technic:lead_ingot"},
			{"basic_materials:copper_wire", "basic_materials:copper_wire", "basic_materials:copper_wire"},
			{"technic:lead_ingot",  "technic:lead_ingot",  "technic:lead_ingot"},
		},
		replacements = {
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
		}
	},
	{output = "technic:control_logic_unit", recipe = {
			{"", "basic_materials:gold_wire", ""},
			{"default:copper_ingot", "elepower_dynamics:silicon_wafer", "default:copper_ingot"},
			{"", "technic:chromium_ingot", ""},
		},
		replacements = {
			{"basic_materials:gold_wire", "basic_materials:empty_spool"},
		}
	},
	{output = "elepower_machines:heavy_filter",	recipe = {
			{"elepower_dynamics:steel_plate", "fluid_transfer:fluid_duct", "elepower_dynamics:steel_plate"},
			{"basic_materials:silicon", "elepower_dynamics:servo_valve", "basic_materials:silicon"},
			{"technic:carbon_cloth", "fluid_transfer:fluid_duct", "technic:carbon_cloth"}
		}
	},
	{output = "elepower_dynamics:axe_iron", recipe = {
			{"technic:cast_iron_ingot", "technic:cast_iron_ingot"},
			{"technic:cast_iron_ingot", "group:stick"},
			{"", "group:stick"},
		}
	},
	{output = "elepower_dynamics:iron_gear", recipe = {
			{"", "technic:cast_iron_ingot", ""},
			{"technic:cast_iron_ingot", "", "technic:cast_iron_ingot"},
			{"", "technic:cast_iron_ingot", ""},
		}
	},
	{type = "cooking", output = "elepower_dynamics:iron_ingot", recipe = "default:iron_lump"},
	{output = "elepower_dynamics:pick_iron", recipe = {
			{"technic:cast_iron_ingot", "technic:cast_iron_ingot", "technic:cast_iron_ingot"},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		}
	},
	{output = "elepower_dynamics:shovel_iron", recipe = {
			{"technic:cast_iron_ingot"},
			{"group:stick"},
			{"group:stick"},
		}
	},
	{output = "elepower_dynamics:sword_iron", recipe = {
			{"technic:cast_iron_ingot"},
			{"technic:cast_iron_ingot"},
			{"group:stick"},
		}
	},
	{output = "technic:lava_can", recipe = {
			{"elepower_dynamics:zinc_ingot", "technic:stainless_steel_ingot", "elepower_dynamics:zinc_ingot"},
			{"technic:stainless_steel_ingot", "", "technic:stainless_steel_ingot"},
			{"elepower_dynamics:zinc_ingot", "technic:stainless_steel_ingot", "elepower_dynamics:zinc_ingot"},
		}
	},
	{output = "elepower_dynamics:axe_lead", recipe = {
			{"technic:lead_ingot", "technic:lead_ingot"},
			{"technic:lead_ingot", "group:stick"},
			{"", "group:stick"},
		}
	},
	{output = "elepower_dynamics:lead_gear", recipe = {
			{"", "technic:lead_ingot", ""},
			{"technic:lead_ingot", "", "technic:lead_ingot"},
			{"", "technic:lead_ingot", ""},
		}
	},
	{type = "cooking", output = "elepower_dynamics:lead_ingot", recipe = "technic:lead_ingot"},
	{type = "cooking", output = "technic:lead_ingot", recipe = "elepower_dynamics:lead_ingot"},
	{output = "elepower_dynamics:pick_lead", recipe = {
			{"technic:lead_ingot", "technic:lead_ingot", "technic:lead_ingot"},
			{"", "group:stick", ""},
			{"", "group:stick", ""},
		}
	},
	{output = "elepower_dynamics:shovel_lead", recipe = {
			{"technic:lead_ingot"},
			{"group:stick"},
			{"group:stick"},
		}
	},
	{output = "basic_materials:lead_strip 12", recipe = {
			{"", "group:lead_ingot"},
			{"group:lead_ingot", ""},
		}
	},
	{output = "elepower_dynamics:sword_lead", recipe = {
			{"technic:lead_ingot"},
			{"technic:lead_ingot"},
			{"group:stick"},
		}
	},
	{output = "technic:lv_led 2", recipe = {
			{"", "basic_materials:plastic_sheet", ""},
			{"basic_materials:plastic_sheet", "elepower_dynamics:silicon_wafer_doped", "basic_materials:plastic_sheet"},
			{"", "basic_materials:silver_wire", ""},
		},
		replacements = {
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
		}
	},
	{output = "elepower_dynamics:opaque_duct 3", recipe = {
			{"technic:lead_ingot",  "technic:lead_ingot",  "technic:lead_ingot"},
			{"fluid_transfer:fluid_duct", "fluid_transfer:fluid_duct", "fluid_transfer:fluid_duct"},
			{"technic:lead_ingot",  "technic:lead_ingot",  "technic:lead_ingot"},
		}
	},
	{output = "elepower_machines:power_cell_0", recipe = {
			{"technic:lead_ingot", "elepower_dynamics:control_circuit", "technic:lead_ingot"},
			{"elepower_dynamics:wound_copper_coil", "elepower_machines:machine_block", "elepower_dynamics:wound_copper_coil"},
			{"technic:lead_ingot", "elepower_dynamics:battery", "technic:lead_ingot"},
		}
	},
	{output = "elepower_dynamics:pv_cell", recipe = {
			{"default:glass", "default:glass", "default:glass"},
			{"group:color_blue", "technic:doped_silicon_wafer", "group:color_blue"},
			{"default:mese_crystal_fragment", "elepower_dynamics:wound_copper_coil", "default:mese_crystal_fragment"}
		}
	},
	{output = "technic:river_water_can", recipe = {
			{"elepower_dynamics:zinc_ingot", "technic:rubber", "elepower_dynamics:zinc_ingot"},
			{"default:steel_ingot", "", "default:steel_ingot"},
			{"elepower_dynamics:zinc_ingot", "default:steel_ingot", "elepower_dynamics:zinc_ingot"},
		}
	},
	{type = "fuel",	recipe = "group:sawdust", time = 6},
	{output = "elepower_machines:sawmill", recipe = {
			{"", "elepower_dynamics:integrated_circuit", ""},
			{"elepower_dynamics:steel_gear", "elepower_machines:machine_block", "elepower_dynamics:steel_gear"},
			{"technic:lead_ingot", "elepower_dynamics:diamond_gear", "technic:lead_ingot"},
		}
	},
	{output = "technic:supply_converter 1",	recipe = {
			{"basic_materials:gold_wire", "technic:rubber", "elepower_dynamics:silicon_wafer_doped"},
			{"technic:mv_transformer", "technic:machine_casing", "technic:lv_transformer"},
			{"technic:mv_cable", "technic:rubber", "technic:lv_cable"},
		},
		replacements = {
			{"basic_materials:gold_wire", "basic_materials:empty_spool"},
		}
	},
	{output = "technic:water_can", recipe = {
			{"elepower_dynamics:zinc_ingot", "technic:rubber", "elepower_dynamics:zinc_ingot"},
			{"technic:carbon_steel_ingot", "", "technic:carbon_steel_ingot"},
			{"elepower_dynamics:zinc_ingot", "technic:carbon_steel_ingot", "elepower_dynamics:zinc_ingot"},
		}
	},
	{output = "elepower_dynamics:wound_copper_coil", recipe = {
			{"", "default:copper_ingot", ""},
			{"default:copper_ingot", "group:iron_ingot", "default:copper_ingot"},
			{"", "default:copper_ingot", ""}
		}
	},
	{output = "elepower_dynamics:wound_copper_coil", recipe = {
			{"", "basic_materials:copper_wire", ""},
			{"basic_materials:copper_wire", "group:iron_ingot", "basic_materials:copper_wire"},
			{"", "basic_materials:copper_wire", ""}
		},
		replacements = {
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
			{"basic_materials:copper_wire", "basic_materials:empty_spool"},
		}
	},
	{output = "elepower_dynamics:wound_silver_coil", recipe = {
			{"", "moreores:silver_ingot", ""},
			{"moreores:silver_ingot", "group:zinc_ingot", "moreores:silver_ingot"},
			{"", "moreores:silver_ingot", ""}
		}
	},
	{output = "elepower_dynamics:wound_silver_coil", recipe = {
			{"", "basic_materials:silver_wire", ""},
			{"basic_materials:silver_wire", "group:zinc_ingot", "basic_materials:silver_wire"},
			{"", "basic_materials:silver_wire", ""}
		},
		replacements = {
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
		}
	},
	{type = "cooking", output = "elepower_dynamics:zinc_ingot",	recipe = "technic:zinc_ingot"},
	{type = "cooking", output = "technic:zinc_ingot", recipe = "elepower_dynamics:zinc_ingot"},
}

for _, data in pairs(recipes) do
	minetest.register_craft({type = data.type or "shaped", output = data.output, recipe = data.recipe, replacements = data.replacements, cooktime = data.time, burntime = data.time})
end

--Carbon fiber armor
if minetest.get_modpath ("elepower_tools") then
	minetest.register_craft({output = "elepower_tools:boots_carbon", recipe = {
			{"technic:carbon_cloth", "", "technic:carbon_cloth"},
			{"technic:carbon_cloth", "", "technic:carbon_cloth"},
		}
	})
	
	minetest.register_craft({output = "elepower_tools:chestplate_carbon", recipe = {
			{"technic:carbon_cloth", "", "technic:carbon_cloth"},
			{"technic:carbon_cloth", "technic:carbon_cloth", "technic:carbon_cloth"},
			{"technic:carbon_cloth", "technic:carbon_cloth", "technic:carbon_cloth"},
		}
	})
	
	minetest.register_craft({output = "elepower_tools:helmet_carbon", recipe = {
			{"technic:carbon_cloth", "technic:carbon_cloth", "technic:carbon_cloth"},
			{"technic:carbon_cloth", "", "technic:carbon_cloth"},
		}
	})
	
	minetest.register_craft({ output = "elepower_tools:leggings_carbon", recipe = {
			{"technic:carbon_cloth", "technic:carbon_cloth", "technic:carbon_cloth"},
			{"technic:carbon_cloth", "", "technic:carbon_cloth"},
			{"technic:carbon_cloth", "", "technic:carbon_cloth"},
		}
	})
end

--Extracting
technic.register_extractor_recipe({input = {"elepower_dynamics:coal_dust"},	output = "dye:black 2",})

--Machine block and nuclear waste
if minetest.get_modpath("elepower_nuclear") then
	minetest.register_craft({output = "elepower_nuclear:machine_block", recipe = {
			{"elepower_dynamics:induction_coil_advanced", "elepower_dynamics:graphite_ingot", "elepower_dynamics:induction_coil_advanced"},
			{"elepower_dynamics:graphite_ingot", "technic:lead_block", "elepower_dynamics:graphite_ingot"},
			{"technic:lead_block", "elepower_dynamics:graphite_ingot", "technic:lead_block"},
		}
	})
	
	minetest.register_craft({output = "elepower_nuclear:nuclear_waste 5", recipe = {
			{"elepower_nuclear:fuel_rod_depleted"}
		},
		replacements = {
			{"elepower_nuclear:fuel_rod_depleted", "elepower_nuclear:fuel_rod_empty"},
		}
	})
end

--Solar panel
if minetest.get_modpath("mesecons_materials") then
	minetest.register_craft({output = "technic:solar_panel", recipe = {
			{"elepower_dynamics:silicon_wafer_doped", "elepower_dynamics:silicon_wafer_doped", "elepower_dynamics:silicon_wafer_doped"},
			{"basic_materials:silver_wire", "technic:lv_cable", "mesecons_materials:glue"},
		},
		replacements = {
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
		}
	})
else
	minetest.register_craft({output = "technic:solar_panel", recipe = {
			{"elepower_dynamics:silicon_wafer_doped", "elepower_dynamics:silicon_wafer_doped", "elepower_dynamics:silicon_wafer_doped"},
			{"basic_materials:silver_wire", "technic:lv_cable", "technic:raw_latex"},
		},
		replacements = {
			{"basic_materials:silver_wire", "basic_materials:empty_spool"},
		}
	})
end

--Soldering
elepm.register_craft({
	type   = "solder",
	recipe = {"elepower_dynamics:induction_coil 4", "basic_materials:copper_wire", "technic:zinc_dust 2"},
	output = "elepower_dynamics:induction_coil_advanced",
	time   = 18
})

elepm.register_craft({
	type   = "solder",
	recipe = {"elepower_dynamics:silicon_wafer_doped", "elepower_dynamics:chip 4", "technic:lead_ingot 2"},
	output = "elepower_dynamics:microcontroller",
	time   = 8,
})

elepm.register_craft({
	type   = "solder",
	recipe = {"technic:doped_silicon_wafer", "elepower_dynamics:chip 4", "elepower_dynamics:lead_ingot 2"},
	output = "elepower_dynamics:microcontroller",
	time   = 8,
})

elepm.register_craft({
	type   = "solder",
	recipe = {"technic:doped_silicon_wafer", "elepower_dynamics:chip 4", "technic:lead_ingot 2"},
	output = "elepower_dynamics:microcontroller",
	time   = 8,
})
