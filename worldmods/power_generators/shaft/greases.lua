
local S = power_generators.translator

minetest.register_craftitem("power_generators:ideal_grease", {
    description = S("Ideal Grease"),
    _agrease = 1,
    _qgrease = 1,
    _inspect_msg_func = power_generators.grease_inspect_msg,
    on_use = power_generators.apply_grease,
  })
appliances.add_item_help("power_generators:ideal_grease", "Can be used as grease.")

