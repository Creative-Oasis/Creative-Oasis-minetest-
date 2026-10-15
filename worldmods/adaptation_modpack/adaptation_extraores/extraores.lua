
local lumps = {
  aluminium = "bauxite", 
  nickel = "garnierite",
  titanium = "rulite",
  tungsten = "wolfranite",
  lithium = "spodumene",
  platinum = "platinum",
  halite = "halite",
  silver = "silver",
}

for metal, lump in pairs(lumps) do
  adaptation_lib.add_item("lump_"..lump, {
      name = "hades_extraores:"..lump.."_lump",
    })
  adaptation_lib.add_item("lump_"..metal, {
      name = "hades_extraores:"..lump.."_lump",
    })
end

local metals = {"aluminium", "nickel", "titanium", "tungsten", "lithium", "platinum", "silver"}

for _, metal in pairs(metals) do
  adaptation_lib.add_item("ingot_"..metal, {
      name = "hades_extraores:"..metal.."_ingot",
    })
  adaptation_lib.add_item("block_"..metal, {
      name = "hades_extraores:"..metal.."_block",
    })
end

adaptation_lib.add_item("block_halite", {
    name = "hades_extraores:halite_block",
  })

