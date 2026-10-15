
if minetest.get_modpath("basic_materials") then
  minetest.override_item("basic_materials:gear_steel", {
      groups = {shaft_gear = 1},
    })
end

if minetest.get_modpath("farming") then
  if minetest.registered_items["farming:hemp_oil"] then
    minetest.override_item("farming:hemp_oil", {
        _agrease = 1,
        _qgrease = 0.5,
        _grease_empty = "vessels:glass_bottle",
        _inspect_msg_func = power_generators.grease_inspect_msg,
        on_use = power_generators.apply_grease,
      })
    appliances.add_item_help("farming:hemp_oil", "Can be used as grease.")
  end
end

if minetest.get_modpath("hades_extrafarming") then
  minetest.override_item("hades_extrafarming:hemp_oil", {
      _agrease = 1,
      _qgrease = 0.5,
      _grease_empty = "vessels:glass_bottle",
      _inspect_msg_func = power_generators.grease_inspect_msg,
      on_use = power_generators.apply_grease,
    })
  appliances.add_item_help("hades_extrafarming:hemp_oil", "Can be used as grease.")
end

