
local items = {
  glass = "default:glass",
  obsidian_glass = "default:obsidian_glass",
  glow_grass = "moreblocks:clean_super_glow_grass",
  plastic_strip = "basic_materials:plastic_strip",
  plastic_sheet = "basic_materials:plastic_sheet",
  solar_panel = "mesecons_solarpanel:solar_panel_off",
  clu = "technic:control_logic_unit",
  mcu = "mesecons_microcontroller:microcontroller0000",
  battery = "technic:battery",
  laser = "default:mese_crystal",
  crystal = "basic_materials:energy_crystal_simple",
}

if minetest.get_modpath("hades_core") then
  items.glass = "hades_core:glass"
  items.obsidian_glass = "hades_core:obsidian_glass"
  items.laser = "hades_core:mese_crystal"
end
if minetest.get_modpath("hades_moreblocks") then
  items.glow_grass = "hades_moreblocks:clean_super_glow_grass"
end
if minetest.get_modpath("hades_technic") then
  items.clu = "hades_technic:control_logic_unit"
  items.battery = "hades_technic:battery_lithium"
end

minetest.register_craft({
    output = "inspect_tool:hand_glass",
    recipe = {
      {"", items.plastic_sheet, ""},
      {items.plastic_sheet, items.glass, items.plastic_sheet},
      {"", items.plastic_sheet, ""},
    },
  })

minetest.register_craft({
    output = "inspect_tool:hand_computer",
    recipe = {
      {items.solar_panel, items.plastic_sheet, items.solar_panel},
      {items.plastic_sheet, items.glass, items.plastic_sheet},
      {items.clu, items.plastic_strip, items.battery},
    },
  })

minetest.register_craft({
    output = "inspect_tool:hand_laser",
    recipe = {
      {items.battery, "inspect_tool:hand_computer", items.battery},
      {items.mcu, items.laser, items.clu},
      {"", items.obsidian_glass, ""},
    },
  })

minetest.register_craft({
    output = "inspect_tool:hand_item_namer",
    recipe = {
      {"", items.plastic_sheet, ""},
      {items.plastic_sheet, items.crystal, items.plastic_sheet},
      {"", items.plastic_sheet, ""},
    },
  })

