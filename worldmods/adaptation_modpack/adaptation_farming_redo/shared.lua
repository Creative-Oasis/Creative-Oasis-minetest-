
local farming_mod = "farming"
if minetest.get_modpath("hades_extrafarming") then
  farming_mod = "hades_extrafarming"
end

adaptation_lib.add_item("seed_barley", {
    name = farming_mod..":seed_barley",
  })

adaptation_lib.add_item("hemp_fibre", {
    name = farming_mod..":hemp_fibre",
  })
adaptation_lib.add_item("hemp_rope", {
    name = farming_mod..":hemp_rope",
    lists = {"rope"},
  })
adaptation_lib.add_item("hemp_oil", {
    name = farming_mod..":hemp_oil",
    lists = {"oil"},
  })
adaptation_lib.add_item("sunflower_oil", {
    name = farming_mod..":subflower_oil",
    lists = {"oil"},
  })

local empty_glass = adaptation_lib.get_item("drinking_glass")

adaptation_lib.add_item("glass_water", {
    name = farming_mod..":glass_water",
    name_empty = adaptation_lib.get_item_name(empty_glass),
  })

