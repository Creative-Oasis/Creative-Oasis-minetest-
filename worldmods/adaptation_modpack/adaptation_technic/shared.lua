
local technic_mod = "technic"

if minetest.get_modpath("hades_technic") then
  technic_mod = "hades_technic"
end

adaptation_lib.add_item("ingot_carbon_steel", {
    name = technic_mod..":carbon_steel_ingot",
  })
adaptation_lib.add_item("ingot_stainless_steel", {
    name = technic_mod..":stainless_steel_ingot",
  })

adaptation_lib.add_item("block_carbon_steel", {
    name = technic_mod..":carbon_steel_block",
  })
adaptation_lib.add_item("block_stainless_steel", {
    name = technic_mod..":stainless_steel_block",
  })


adaptation_lib.add_item("tramsformer_lv", {
    name = technic_mod..":lv_transformer",
  })
adaptation_lib.add_item("tramsformer_mv", {
    name = technic_mod..":mv_transformer",
  })
adaptation_lib.add_item("tramsformer_hv", {
    name = technic_mod..":hv_transformer",
  })

adaptation_lib.add_item("rubber", {
    name = technic_mod..":rubber",
  })

adaptation_lib.add_item("graphite", {
    name = technic_mod..":graphite",
  })

adaptation_lib.add_item("control_logic_unit", {
    name = technic_mod..":control_logic_unit",
  })

adaptation_lib.add_item("cable_LV", {
    name = technic_mod..":lv_cable",
  })
adaptation_lib.add_item("cable_MV", {
    name = technic_mod..":mv_cable",
  })
adaptation_lib.add_item("cable_HV", {
    name = technic_mod..":hv_cable",
  })

