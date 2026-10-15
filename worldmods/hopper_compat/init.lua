--Note: Connected Chests support was removed because hopper (FaceDeer's version) and Connected
--      Chests support it themselves now

-- TO DO: Add connected_chests support for tenplus1's version of hopper.

-- Make the hoppers work with a chest when it is open because
-- for some reason the hopper mod doesn't do that?
if minetest.settings:get_bool("open_chest_support") or true then
	hopper:add_container({
		{"top", "default:chest_open", "main"},
		{"side", "default:chest_open", "main"},
		{"bottom", "default:chest_open", "main"},
        -- New chests
		{"top", "signs_bot:chest", "main"},
		{"side", "signs_bot:chest", "main"},
		{"bottom", "signs_bot:chest", "main"},

		{"top", "nanotech:carbon_chest", "main"},
		{"side", "nanotech:carbon_chest", "main"},
		{"bottom", "nanotech:carbon_chest", "main"},
	})
end

-- Add support for elepoer stuff.
if minetest.get_modpath("elepower_machines") then
	hopper:add_container({
		{"top", "elepower_machines:alloy_furnace", "dst"}, 
		{"side", "elepower_machines:alloy_furnace", "dst"},
		{"bottom", "elepower_machines:alloy_furnace", "src"},

		{"top", "elepower_machines:bucketer", "dst"}, 
		{"side", "elepower_machines:bucketer", "dst"},
		{"bottom", "elepower_machines:bucketer", "src"},

		{"top", "elepower_machines:canning_machine", "dst"}, 
		{"side", "elepower_machines:canning_machine", "dst"},
		{"bottom", "elepower_machines:canning_machine", "src"},

		{"top", "elepower_machines:coal_alloy_furnace", "fuel"}, 
		{"bottom", "elepower_machines:coal_alloy_furnace", "fuel"},
		{"side", "elepower_machines:coal_alloy_furnace", "fuel"}, 

		{"top", "elepower_machines:compressor", "dst"}, 
		{"side", "elepower_machines:compressor", "dst"},
		{"bottom", "elepower_machines:compressor", "src"}, 

		{"top", "elepower_machines:furnace", "dst"}, 
		{"side", "elepower_machines:furnace", "dst"},
		{"bottom", "elepower_machines:furnace", "src"}, 

		{"top", "elepower_machines:generator", "src"}, 
		{"side", "elepower_machines:generator", "src"}, 

		{"top", "elepower_machines:generator_active", "src"}, 
		{"side", "elepower_machines:generator_active", "src"}, 

		{"top", "elepower_machines:grindstone", "dst"}, 
		{"side", "elepower_machines:grindstone", "src"},
		{"bottom", "elepower_machines:grindstone", "src"},

		{"top", "elepower_machines:pcb_plant", "dst"}, 
		{"side", "elepower_machines:pcb_plant", "dst"},
		{"bottom", "elepower_machines:pcb_plant", "src"},

		{"top", "elepower_machines:pulverizer", "dst"}, 
		{"side", "elepower_machines:pulverizer", "dst"},
		{"bottom", "elepower_machines:pulverizer", "src"},

		{"top", "elepower_machines:pulverizer_active", "dst"}, 
		{"bottom", "elepower_machines:pulverizer_active", "src"},
		{"side", "elepower_machines:pulverizer_active", "src"},

		{"bottom", "elepower_machines:lava_cooler", "main"},

		{"top", "elepower_machines:sawmill", "dst"}, 
		{"side", "elepower_machines:sawmill", "dst"},
		{"bottom", "elepower_machines:sawmill", "src"},

		{"top", "elepower_machines:solderer", "dst"}, 
		{"side", "elepower_machines:solderer", "dst"},
		{"bottom", "elepower_machines:solderer", "src"},
	})
end

-- Add Support for techinc chests.
if minetest.get_modpath("technic_chests") then
	hopper:add_container({
		{"top", "technic:iron_chest", "main"}, 
		{"bottom", "technic:iron_chest", "main"},
		{"side", "technic:iron_chest", "main"}, 

		{"top", "technic:copper_chest", "main"}, 
		{"bottom", "technic:copper_chest", "main"},
		{"side", "technic:copper_chest", "main"}, 

		{"top", "technic:silver_chest", "main"}, 
		{"bottom", "technic:silver_chest", "main"},
		{"side", "technic:silver_chest", "main"}, 

		{"top", "technic:gold_chest", "main"}, 
		{"bottom", "technic:gold_chest", "main"},
		{"side", "technic:gold_chest", "main"}, 

		{"top", "technic:mithril_chest", "main"}, 
		{"bottom", "technic:mithril_chest", "main"},
		{"side", "technic:mithril_chest", "main"}, 
	})
end

if minetest.get_modpath("technic") then
	hopper:add_container({
		{"top", "technic:injector", "main"}, 
		{"bottom", "technic:injector", "main"},
		{"side", "technic:injector", "main"}, 
	})
end

-- Add support for pipeworks autocrafter.
if minetest.get_modpath("pipeworks") then
	hopper:add_container({
		{"top", "pipeworks:autocrafter", "dst"}, 
		{"bottom", "pipeworks:autocrafter", "src"},
		{"side", "pipeworks:autocrafter", "src"},
	})
end

-- Terumet machine support (CubicMelon)
if minetest.get_modpath("terumet") then
	hopper:add_container({

		-- Alloy Smelter
		{"top",    "terumet:mach_asmelt", "input"},
		{"side",   "terumet:mach_asmelt", "input"},
		{"bottom", "terumet:mach_asmelt", "output"},

		-- Crusher
		{"top",    "terumet:mach_crusher", "input"},
		{"side",   "terumet:mach_crusher", "input"},
		{"bottom", "terumet:mach_crusher", "output"},

		-- High-Temp Furnace
		{"top",    "terumet:mach_htfurn", "input"},
		{"side",   "terumet:mach_htfurn", "input"},
		{"bottom", "terumet:mach_htfurn", "output"},

		-- Heat-Transfer Furnace
		{"top",    "terumet:mach_htr_furnace", "input"},
		{"side",   "terumet:mach_htr_furnace", "input"},
		{"bottom", "terumet:mach_htr_furnace", "output"},

		-- Lava Melter
		{"top",    "terumet:mach_lavam", "input"},
		{"side",   "terumet:mach_lavam", "input"},
		{"bottom", "terumet:mach_lavam", "output"},

		-- Mese Generator (input + output)
		{"top",    "terumet:mach_meseg", "input"},
		{"side",   "terumet:mach_meseg", "input"},
		{"bottom", "terumet:mach_meseg", "output"},  -- now hopper can extract

		-- Replicator Machine
		{"top",    "terumet:mach_repm", "input"},
		{"side",   "terumet:mach_repm", "input"},
		{"bottom", "terumet:mach_repm", "output"},

		-- Vacuum Oven
		{"top",    "terumet:mach_vcoven", "input"},
		{"side",   "terumet:mach_vcoven", "input"},
		{"bottom", "terumet:mach_vcoven", "output"},

		-- Vulcanizer
		{"top",    "terumet:mach_vulcan", "input"},
		{"side",   "terumet:mach_vulcan", "input"},
		{"bottom", "terumet:mach_vulcan", "output"},

		-- Mese Garden
		{"top",    "terumet:mese_garden", "input"},
		{"side",   "terumet:mese_garden", "input"},
		{"bottom", "terumet:mese_garden", "output"},
	})
end

