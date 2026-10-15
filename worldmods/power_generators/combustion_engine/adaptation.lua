
if minetest.get_modpath("biofuel") then
  if minetest.registered_items["biofuel:can"] then
    minetest.override_item("biofuel:phial_fuel", {
        _fuel_amount = 1,
        _fuel_energy = 1.0,
        _fuel_empty = "biofuel:phial",
      })
    minetest.override_item("biofuel:bottle_fuel", {
        _fuel_amount = 8,
        _fuel_energy = 1.0,
        _fuel_empty = "vessels:glass_bottle",
      })
    minetest.override_item("biofuel:fuel_can", {
        _fuel_amount = 64,
        _fuel_energy = 1.0,
        _fuel_empty = "biofuel:can",
      })
	else
    minetest.override_item("biofuel:phial_fuel", {
        _fuel_amount = 1,
        _fuel_energy = 1.0,
      })
    minetest.override_item("biofuel:bottle_fuel", {
        _fuel_amount = 8,
        _fuel_energy = 1.0,
      })
    minetest.override_item("biofuel:fuel_can", {
        _fuel_amount = 64,
        _fuel_energy = 1.0,
      })
  end
end
if minetest.get_modpath("hades_biofuel") then
  minetest.override_item("hades_biofuel:phial_fuel", {
      _fuel_amount = 1,
      _fuel_energy = 1.0,
      _fuel_empty = "hades_biofuel:phial",
    })
  minetest.override_item("hades_biofuel:bottle_fuel", {
      _fuel_amount = 8,
      _fuel_energy = 1.0,
      _fuel_empty = "vessels:glass_bottle",
    })
  minetest.override_item("hades_biofuel:fuel_can", {
      _fuel_amount = 64,
      _fuel_energy = 1.0,
      _fuel_empty = "hades_biofuel:can",
    })
end

