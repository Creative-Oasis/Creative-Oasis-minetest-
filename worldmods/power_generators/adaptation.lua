
power_generators.adaptation = {}
local adaptation = power_generators.adaptation

-- items
adaptation.iron_ingot = adaptation_lib.get_item({"ingot_steel", "ingot_iron"})
adaptation.strong_ingot = adaptation_lib.get_item({"ingot_stainless_steel", "ingot_steel", "ingot_iron"})
adaptation.metal_ingot = adaptation_lib.get_item({"ingot_carbon_steel", "ingot_steel", "ingot_iron"})
adaptation.copper_ingot = adaptation_lib.get_item({"ingot_copper"})
adaptation.mese_fragment = adaptation_lib.get_item({"mese_crystal_fragment"})
adaptation.metal_block = adaptation_lib.get_item({"block_carbon_steel","block_steel", "block_iron"})
adaptation.string = adaptation_lib.get_item({"string"})
  
adaptation.plastic_sheet = adaptation_lib.get_item({"sheet_plastic"})
adaptation.plastic_strip = adaptation_lib.get_item({"strip_plastic"})
adaptation.steel_strip = adaptation_lib.get_item({"strip_steel"})
adaptation.steel_bar = adaptation_lib.get_item({"bar_carbon_steel", "bar_steel"})
adaptation.copper_wire = adaptation_lib.get_item({"wire_copper"})
adaptation.empty_spool = adaptation_lib.get_item({"spool_empty"})
adaptation.controller = adaptation_lib.get_item({"control_logic_unit","integrated_circuit"})
  
adaptation.gear = adaptation_lib.get_item({"gear_steel"})
adaptation.electric_motor = adaptation_lib.get_item({"motor_electric"})
adaptation.transformer = adaptation_lib.get_item({"transformer_lv", "wire_gold"})
  
adaptation.magnet = adaptation_lib.get_item({"mese_crystal_fragment"})
adaptation.glow_crystal = adaptation_lib.get_item({"glowcrystal", "mese_crystal_fragment"})
  
adaptation.dye_yellow = adaptation_lib.get_item({"dye_yellow"})
  
adaptation.valve = adaptation_lib.get_item({"valve_servo","valve"})
adaptation.rubber = adaptation_lib.get_item({"rubber", "fiber"})

adaptation.biofuel_phial = adaptation_lib.get_item("biofuel_phial")
adaptation.biofuel_bottle = adaptation_lib.get_item("biofuel_bottle")
adaptation.biofuel_can = adaptation_lib.get_item("biofuel_can")

-- mods
adaptation.screwdriver_mod = adaptation_lib.get_mod("screwdriver") or {}

