
local S = power_generators.translator;

local adaptation = power_generators.adaptation

local Cable = power_generators.electric_cable

local tubelib2_side = {
    right = "R",
    left = "L",
    front = "F",
    back = "B",
    top = "U",
    bottom = "D",
  }
local generator_connect_sides = {"front", "back"}

local function gen_on_blast(drop)
  return function(pos, intensity)
    if intensity < 0.5 then
      return {}
    end
    local node = minetest.get_node(pos)
    minetest.remove_node(pos)
    Cable:after_dig_tube(pos, node)
    return {drop}
  end
end

local node_sounds = nil
if minetest.get_modpath("default") then
  node_sounds = default.node_sound_metal_defaults()
end
if minetest.get_modpath("hades_sounds") then
  node_sounds = hades_sounds.node_sound_metal_defaults()
end
if minetest.get_modpath("sounds") then
  node_sounds = sounds.node_metal()
end

minetest.register_node("power_generators:power_meter", {
  description = S("PG Electric Power Meter"),
  tiles = {
    -- up, down, right, left, back, front
    "power_generators_electric_power_meter_side.png",
    "power_generators_electric_power_meter_side.png",
    "power_generators_electric_power_meter_side.png",
    "power_generators_electric_power_meter_side.png",
    "power_generators_electric_power_meter_back.png",
    {
      image = "power_generators_electric_power_meter_front_active.png",
      backface_culling = false,
      animation = {
        type = "vertical_frames",
        aspect_w = 32,
        aspect_h = 32,
        length = 1.5
      }
    },
  },
  
  paramtype2 = "facedir",
  is_ground_content = false,
  groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
      },
  sounds = node_sounds,
  
  _generator_connect_sides = generator_connect_sides,
  _generator_powered_valid_sides = {F = true, B = true},
  
  --after_dig_node = function(pos, oldnode, oldmetadata, digger)
  after_dig_node = function(pos, oldnode)
    Cable:after_dig_tube(pos, oldnode)
  end,
  --after_place_node = function(pos, placer, itemstack, pointed_thing)
  after_place_node = function(pos)
    Cable:after_place_node(pos)
  end,
  --tubelib2_on_update2 = function(pos, dir1, tlib2, node)
  tubelib2_on_update2 = function()
    print("tubelib2_on_update2 power_meter")
  end,
  on_rotate = adaptation.screwdriver_mod.disallow, -- important!
  on_blast = gen_on_blast("power_generators:power_meter"),
  
  on_construct = function(pos)
    minetest.get_node_timer(pos):start(1)
  end,
  --on_timer = function(pos, elapsed)
  on_timer = function(pos)
    local meta = minetest.get_meta(pos)
    local generators_input = 0
    for _, dir in pairs(generator_connect_sides) do
      dir = tubelib2_side[dir]
      generators_input = generators_input + meta:get_int("input_"..dir)
      meta:set_int("input_"..dir, 0)
    end
    meta:set_string("infotext", S("Power @1 PG EU", generators_input))
    local total_demand = power_generators.update_generator_supply(generator_connect_sides, pos, {generator_output = generators_input})
    meta:set_int("generator_demand", total_demand)
    local need_update = meta:get_int("update")
    if (not need_update) and (generators_input==0) then
      return false
    end
    meta:set_int("update", 0)
    return true
  end,
  on_punch = function(pos)
    local timer = minetest.get_node_timer(pos)
    if not timer:is_started() then
      timer:start(1)
    end
  end,
  
  set_PG_power_input = function(meta, dir, power)
    meta:set_int("input_"..dir, power)
  end,
})
Cable:add_secondary_node_names({"power_generators:power_meter"})
--Cable:add_special_node_names({"power_generators:power_meter"})

