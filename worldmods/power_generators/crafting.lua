
local adaptation = power_generators.adaptation

local N = adaptation_lib.get_item_name

adaptation_lib.check_keys_aviable("[power_generators] Crafting: ", adaptation, {"iron_ingot", "strong_ingot", "metal_ingot", "copper_ingot", "mese_fragment", "string", "plastic_sheet", "plastic_strip", "steel_strip", "steel_bar", "copper_wire", "empty_spool", "controller", "gear", "electric_motor", "transformer", "magnet", "glow_crystal", "dye_yellow", "valve", "rubber"})

minetest.register_craft({
    output = "power_generators:electric_cableS 6",
    recipe = {
      {N(adaptation.plastic_sheet), N(adaptation.dye_yellow), ""},
      {"", N(adaptation.copper_wire), ""},
      {"", "", N(adaptation.plastic_sheet)},
    },
    replacements = {{N(adaptation.copper_wire), N(adaptation.empty_spool)}},
  })

minetest.register_craft({
    output = "power_generators:junction_box",
    recipe = {
      {"power_generators:electric_cableS", "power_generators:electric_cableS", "power_generators:electric_cableS"},
      {N(adaptation.plastic_sheet), N(adaptation.metal_block), N(adaptation.plastic_sheet)},
      {N(adaptation.transformer), N(adaptation.transformer), N(adaptation.transformer)},
    },
    replacements = {{N(adaptation.copper_wire),N(adaptation.empty_spool)}},
  })

minetest.register_craft({
    output = "power_generators:power_meter",
    recipe = {
      {"power_generators:electric_cableS", "power_generators:electric_cableS", "power_generators:electric_cableS"},
      {N(adaptation.plastic_sheet), N(adaptation.plastic_strip), N(adaptation.plastic_sheet)},
      {N(adaptation.transformer), N(adaptation.metal_block), N(adaptation.magnet)},
    },
    replacements = {{N(adaptation.copper_wire),N(adaptation.empty_spool)}},
  })

minetest.register_craft({
    output = "power_generators:charger",
    recipe = {
      {"power_generators:electric_cableS", "power_generators:electric_cableS", "power_generators:electric_cableS"},
      {N(adaptation.plastic_sheet), N(adaptation.metal_block), N(adaptation.plastic_sheet)},
      {N(adaptation.transformer), N(adaptation.controller), N(adaptation.copper_wire)},
    },
    replacements = {
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
    },
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_piston",
    recipe = {
      {adaptation.strong_ingot.name, adaptation.strong_ingot.name, adaptation.strong_ingot.name},
      {"", adaptation.strong_ingot.name, ""},
      {"", adaptation.strong_ingot.name, ""},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_cylinder_body",
    recipe = {
      {adaptation.strong_ingot.name, "", adaptation.strong_ingot.name},
      {adaptation.strong_ingot.name, "", adaptation.strong_ingot.name},
      {adaptation.strong_ingot.name, adaptation.strong_ingot.name, adaptation.strong_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_crankshaft 2",
    recipe = {
      {"", adaptation.strong_ingot.name, adaptation.strong_ingot.name},
      {"", adaptation.strong_ingot.name, ""},
      {adaptation.strong_ingot.name, adaptation.strong_ingot.name, ""},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_spark_plug",
    recipe = {
      {adaptation.copper_ingot.name, N(adaptation.copper_wire), adaptation.copper_ingot.name},
      {"", N(adaptation.mese_fragment), ""},
    },
    replacements = {{N(adaptation.copper_wire),N(adaptation.empty_spool)}},
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_body_2",
    recipe = {
      {"power_generators:combustion_engine_spark_plug", adaptation.metal_ingot.name, "power_generators:combustion_engine_spark_plug"},
      {"power_generators:combustion_engine_piston", "", "power_generators:combustion_engine_piston"},
      {"power_generators:combustion_engine_cylinder_body", "power_generators:combustion_engine_crankshaft", "power_generators:combustion_engine_cylinder_body"},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_body_2_controlled",
    recipe = {
      {"power_generators:combustion_engine_spark_plug", adaptation.metal_ingot.name, "power_generators:combustion_engine_spark_plug"},
      {"power_generators:combustion_engine_piston", N(adaptation.controller), "power_generators:combustion_engine_piston"},
      {"power_generators:combustion_engine_cylinder_body", "power_generators:combustion_engine_crankshaft", "power_generators:combustion_engine_cylinder_body"},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_body_4",
    recipe = {
      {adaptation.metal_ingot.name, adaptation.metal_ingot.name},
      {"power_generators:combustion_engine_body_2","power_generators:combustion_engine_body_2"},
      {"power_generators:combustion_engine_crankshaft","power_generators:combustion_engine_crankshaft"},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_body_6",
    recipe = {
      {adaptation.metal_ingot.name, adaptation.metal_ingot.name, adaptation.metal_ingot.name},
      {"power_generators:combustion_engine_body_2","power_generators:combustion_engine_body_2", "power_generators:combustion_engine_body_2"},
      {"power_generators:combustion_engine_crankshaft","power_generators:combustion_engine_crankshaft","power_generators:combustion_engine_crankshaft"},
    }
  })


--[[
minetest.register_craft({
    output = "power_generators:combustion_engine_body_8",
    recipe = {
      {adaptation.metal_ingot, adaptation.metal_ingot},
      {"power_generators:combustion_engine_body_4","power_generators:combustion_engine_body_4"},
      {"power_generators:combustion_engine_crankshaft","power_generators:combustion_engine_crankshaft"},
    }
  })
--]]

minetest.register_craft({
    output = "power_generators:combustion_engine_two_cylinders",
    recipe = {
      {adaptation.metal_ingot.name, "", adaptation.metal_ingot.name},
      {N(adaptation.copper_wire), "power_generators:combustion_engine_body_2", N(adaptation.copper_wire)},
      {adaptation.metal_ingot.name, "power_generators:shaft", adaptation.metal_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_two_cylinders_controlled",
    recipe = {
      {adaptation.metal_ingot.name, N(adaptation.controller), adaptation.metal_ingot.name},
      {N(adaptation.copper_wire), "power_generators:combustion_engine_body_2_controlled", N(adaptation.copper_wire)},
      {adaptation.metal_ingot.name, "power_generators:shaft", adaptation.metal_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_six_cylinders",
    recipe = {
      {adaptation.metal_ingot.name, "", adaptation.metal_ingot.name},
      {N(adaptation.copper_wire), "power_generators:combustion_engine_body_6", N(adaptation.copper_wire)},
      {adaptation.metal_ingot.name, "power_generators:shaft", adaptation.metal_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_gearbox",
    recipe = {
      {adaptation.metal_ingot.name, N(adaptation.gear), adaptation.metal_ingot.name},
      {adaptation.metal_ingot.name, N(adaptation.gear), adaptation.metal_ingot.name},
      {adaptation.metal_ingot.name, N(adaptation.gear), adaptation.metal_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_alternator",
    recipe = {
      {"", N(adaptation.transformer), ""},
      {"", adaptation.electric_motor.name, ""},
      {adaptation.metal_ingot.name, "", adaptation.metal_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:combustion_engine_fuel_tank",
    recipe = {
      {adaptation.metal_ingot.name, adaptation.metal_ingot.name, adaptation.metal_ingot.name},
      {adaptation.metal_ingot.name, "", adaptation.metal_ingot.name},
      {adaptation.metal_ingot.name, adaptation.metal_ingot.name, adaptation.metal_ingot.name},
    }
  })

minetest.register_craft({
    output = "power_generators:emergency_generator",
    recipe = {
      {adaptation.metal_ingot.name, "power_generators:combustion_engine_fuel_tank", adaptation.metal_ingot.name},
      {"power_generators:combustion_engine_two_cylinders", "power_generators:combustion_engine_gearbox", "power_generators:combustion_engine_alternator"},
      {adaptation.metal_ingot.name, "", adaptation.metal_ingot.name},
    },
  })

minetest.register_craft({
    output = "power_generators:emergency_generator_2",
    recipe = {
      {adaptation.metal_ingot.name, "power_generators:combustion_engine_fuel_tank", adaptation.metal_ingot.name},
      {"power_generators:combustion_engine_two_cylinders_controlled", "power_generators:combustion_engine_gearbox", "power_generators:combustion_engine_alternator"},
      {adaptation.metal_ingot.name, "", adaptation.metal_ingot.name},
    },
  })

minetest.register_craft({
    output = "power_generators:alternator",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),"power_generators:electric_cableS"},
      {N(adaptation.iron_ingot),"power_generators:electric_engine_p24",N(adaptation.iron_ingot)},
      {N(adaptation.transformer),N(adaptation.iron_ingot), N(adaptation.transformer)},
    }
  })

minetest.register_craft({
    output = "power_generators:fuel_hosepipe",
    recipe = {
      {"",N(adaptation.rubber),""},
      {N(adaptation.rubber),"",N(adaptation.rubber)},
      {"",N(adaptation.rubber),""},
    }
  })

minetest.register_craft({
    output = "power_generators:fuel_tank",
    recipe = {
      {"","power_generators:combustion_engine_fuel_tank",N(adaptation.rubber)},
      {"power_generators:combustion_engine_fuel_tank","power_generators:framework","power_generators:combustion_engine_fuel_tank"},
      {"","power_generators:combustion_engine_fuel_tank","power_generators:fuel_hosepipe"},
    }
  })

minetest.register_craft({
    output = "power_generators:gearbox",
    recipe = {
      {N(adaptation.steel_strip),N(adaptation.steel_strip),"power_generators:combustion_engine_gearbox"},
      {N(adaptation.steel_strip),"power_generators:framework","power_generators:shaft"},
      {"power_generators:combustion_engine_gearbox","power_generators:shaft","power_generators:combustion_engine_gearbox"},
    }
  })

minetest.register_craft({
    output = "power_generators:starter_manual",
    recipe = {
      {N(adaptation.steel_bar),N(adaptation.steel_strip),N(adaptation.steel_bar)},
      {N(adaptation.steel_strip),"power_generators:framework","power_generators:shaft"},
      {"power_generators:combustion_engine_gearbox","power_generators:shaft","power_generators:combustion_engine_gearbox"},
    }
  })

if adaptation.valve then
  minetest.register_craft({
      output = "power_generators:combustion_engine_6c",
      recipe = {
        {"power_generators:framework","power_generators:fuel_hosepipe"},
        {N(adaptation.steel_strip),adaptation.valve.name},
        {"power_generators:shaft","power_generators:combustion_engine_six_cylinders"},
      }
    })
end

--[[
minetest.register_craft({
    output = "power_generators:combustion_engine_8c",
    recipe = {
      {"power_generators:framework","power_generators:fuel_hosepipe"},
      {adaptation.steel_strip,adaptation.steel_strip},
      {"power_generators:shaft","power_generators:combustion_engine_eight_cylinders"},
    }
  })
--]]

minetest.register_craft({
    output = "power_generators:shaft 3",
    recipe = {
      {adaptation.strong_ingot.name,},
      {adaptation.strong_ingot.name,},
      {adaptation.strong_ingot.name,},
    }
  })

minetest.register_craft({
    output = "power_generators:framework_base",
    recipe = {
      {"",N(adaptation.steel_bar),""},
      {N(adaptation.steel_bar),"", N(adaptation.steel_bar)},
      {"",N(adaptation.steel_bar),""},
    }
  })

minetest.register_craft({
    type = "shapeless",
    output = "power_generators:framework",
    recipe = {
      N(adaptation.steel_bar),
      N(adaptation.steel_bar),
      N(adaptation.steel_bar),
      N(adaptation.steel_bar),
      "power_generators:framework_base",
      "power_generators:framework_base",
      N(adaptation.steel_bar),
    }
  })

minetest.register_craft({
    output = "power_generators:block_of_3coils",
    recipe = {
      {N(adaptation.copper_wire),N(adaptation.copper_wire),N(adaptation.copper_wire)},
      {N(adaptation.plastic_strip),N(adaptation.plastic_strip),N(adaptation.plastic_strip)},
    },
    replacements = {
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)}},
  })

minetest.register_craft({
    output = "power_generators:block_of_3magnets",
    recipe = {
      {N(adaptation.magnet),N(adaptation.magnet),N(adaptation.magnet)},
      {N(adaptation.plastic_strip),N(adaptation.plastic_strip),N(adaptation.plastic_strip)},
    },
  })

minetest.register_craft({
    output = "power_generators:electric_engine_p6",
    recipe = {
      {N(adaptation.steel_strip),"power_generators:block_of_3coils",N(adaptation.steel_strip)},
      {"power_generators:block_of_3magnets","power_generators:shaft", "power_generators:block_of_3magnets"},
      {N(adaptation.steel_strip),"power_generators:block_of_3coils",N(adaptation.steel_strip)},
    }
  })

minetest.register_craft({
    output = "power_generators:block_of_6coils",
    recipe = {
      {N(adaptation.copper_wire),N(adaptation.copper_wire),N(adaptation.copper_wire)},
      {N(adaptation.plastic_strip),N(adaptation.plastic_strip),N(adaptation.plastic_strip)},
      {N(adaptation.copper_wire),N(adaptation.copper_wire),N(adaptation.copper_wire)},
    },
    replacements = {
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)},
      {N(adaptation.copper_wire),N(adaptation.empty_spool)}},
  })

minetest.register_craft({
    output = "power_generators:block_of_6magnets",
    recipe = {
      {N(adaptation.magnet),N(adaptation.magnet),N(adaptation.magnet)},
      {N(adaptation.plastic_strip),N(adaptation.plastic_strip),N(adaptation.plastic_strip)},
      {N(adaptation.magnet),N(adaptation.magnet),N(adaptation.magnet)},
    },
  })

minetest.register_craft({
    output = "power_generators:electric_engine_p12",
    recipe = {
      {N(adaptation.steel_strip),"power_generators:block_of_6coils",N(adaptation.steel_strip)},
      {"power_generators:block_of_6magnets","power_generators:shaft", "power_generators:block_of_6magnets"},
      {N(adaptation.steel_strip),"power_generators:block_of_6coils",N(adaptation.steel_strip)},
    }
  })

minetest.register_craft({
    output = "power_generators:block_of_12coils",
    recipe = {
      {"power_generators:block_of_6coils",N(adaptation.plastic_strip),"power_generators:block_of_6coils"},
    },
  })

minetest.register_craft({
    output = "power_generators:block_of_12magnets",
    recipe = {
      {"power_generators:block_of_6magnets",N(adaptation.plastic_strip),"power_generators:block_of_6magnets"},
    },
  })

minetest.register_craft({
    output = "power_generators:electric_engine_p24",
    recipe = {
      {N(adaptation.steel_strip),"power_generators:block_of_12coils",N(adaptation.steel_strip)},
      {"power_generators:block_of_12magnets","power_generators:shaft", "power_generators:block_of_12magnets"},
      {N(adaptation.steel_strip),"power_generators:block_of_12coils",N(adaptation.steel_strip)},
    }
  })

minetest.register_craft({
    output = "power_generators:electric_engine_200",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),"power_generators:electric_cableS"},
      {N(adaptation.iron_ingot),"power_generators:electric_engine_p6",N(adaptation.iron_ingot)},
      {"",N(adaptation.iron_ingot),""},
    }
  })

minetest.register_craft({
    output = "power_generators:electric_engine_400",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),"power_generators:electric_cableS"},
      {N(adaptation.iron_ingot),"power_generators:electric_engine_p12",N(adaptation.iron_ingot)},
      {"",N(adaptation.iron_ingot),""},
    }
  })

minetest.register_craft({
    output = "power_generators:electric_engine_800",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),"power_generators:electric_cableS"},
      {N(adaptation.iron_ingot),"power_generators:electric_engine_p24",N(adaptation.iron_ingot)},
      {"",N(adaptation.iron_ingot),""},
    }
  })

minetest.register_craft({
    output = "power_generators:shaft_hor",
    recipe = {
      {"power_generators:framework","power_generators:shaft"},
    }
  })
minetest.register_craft({
    output = "power_generators:shaft_ver",
    recipe = {
      {"power_generators:shaft"},
      {"power_generators:framework",}
    }
  })

minetest.register_craft({
    output = "power_generators:shaft_horLeft",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),"power_generators:shaft"},
      {N(adaptation.iron_ingot),"power_generators:shaft",N(adaptation.iron_ingot)},
      {N(adaptation.gear),N(adaptation.iron_ingot),N(adaptation.gear)},
    }
  })

minetest.register_craft({
    output = "power_generators:shaft_horTop",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),N(adaptation.gear)},
      {N(adaptation.iron_ingot),"power_generators:shaft",N(adaptation.iron_ingot)},
      {N(adaptation.gear),N(adaptation.iron_ingot),"power_generators:shaft"},
    }
  })

minetest.register_craft({
    output = "power_generators:shaft_verFront",
    recipe = {
      {N(adaptation.gear),N(adaptation.iron_ingot),"power_generators:shaft"},
      {N(adaptation.iron_ingot),"power_generators:shaft",N(adaptation.iron_ingot)},
      {"power_generators:framework",N(adaptation.iron_ingot),N(adaptation.gear)},
    }
  })

minetest.register_craft({
    output = "power_generators:shaft_switch",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),N(adaptation.steel_bar)},
      {N(adaptation.iron_ingot),"power_generators:shaft",N(adaptation.iron_ingot)},
      {N(adaptation.gear),N(adaptation.iron_ingot),N(adaptation.gear)},
    }
  })

minetest.register_craft({
    output = "power_generators:shaft_gearbox",
    recipe = {
      {"power_generators:framework",N(adaptation.iron_ingot),N(adaptation.gear)},
      {N(adaptation.iron_ingot),"power_generators:shaft",N(adaptation.iron_ingot)},
      {N(adaptation.gear),N(adaptation.iron_ingot),N(adaptation.gear)},
    }
  })

minetest.register_craft({
    output = "power_generators:rpm_meter",
    recipe = {
      {"power_generators:framework",N(adaptation.controller),"power_generators:electric_cableS"},
      {N(adaptation.glow_crystal),"",N(adaptation.mese_fragment)},
      {N(adaptation.iron_ingot),"power_generators:shaft",N(adaptation.iron_ingot)},
    }
  })

minetest.register_craft({
    output = "power_generators:rpm_meter_watt",
    recipe = {
      {N(adaptation.steel_bar),"",N(adaptation.steel_bar)},
      {N(adaptation.string),"power_generators:shaft",N(adaptation.plastic_sheet)},
      {N(adaptation.steel_bar),"",N(adaptation.steel_bar)},
    }
  })

