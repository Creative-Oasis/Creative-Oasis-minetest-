
local biofuel_mod = "biofuel"

if minetest.get_modpath("hades_biofuel") then
  biofuel_mod = "hades_biofuel"
end

adaptation_lib.add_item("biofuel_phial", {
    name = biofuel_mod..":phial_fuel"
  })
adaptation_lib.add_item("biofuel_bottle", {
    name = biofuel_mod..":bottle_fuel"
  })
adaptation_lib.add_item("biofuel_can", {
    name = biofuel_mod..":fuel_can"
  })

