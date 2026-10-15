local S = power_generators.translator;

local adaptation = power_generators.adaptation

-- for lazy programmers
--local S2P = minetest.string_to_pos
--local P2S = minetest.pos_to_string

local Cable = tubelib2.Tube:new({
  dirs_to_check = {1,2,3,4,5,6},
  max_tube_length = 128,
  show_infotext = false,
  tube_type = "powgencable",
  primary_node_names = {"power_generators:electric_cableS", "power_generators:electric_cableA",
    },
  --after_place_tube = function(pos, param2, tube_type, num_tubes)
  after_place_tube = function(pos, param2, tube_type)
    minetest.swap_node(pos, {name = "power_generators:electric_cable"..tube_type, param2 = param2})
  end,
})

power_generators.electric_cable = Cable

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
  node_sounds = default.node_sound_defaults();
end
if minetest.get_modpath("hades_sounds") then
  node_sounds = hades_sounds.node_sound_defaults();
end
if minetest.get_modpath("sounds") then
  node_sounds = sounds.node();
end

minetest.register_node("power_generators:electric_cableS", {
  description = S("PG Electric Cable"),
  tiles = {
    -- up, down, right, left, back, front
    "power_generators_electric_cable.png",
    "power_generators_electric_cable.png",
    "power_generators_electric_cable.png",
    "power_generators_electric_cable.png",
    "power_generators_electric_cable_end.png",
    "power_generators_electric_cable_end.png",
  },
  paramtype2 = "facedir", -- important!
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-1/16, -1/16, -1/2,  1/16, 1/16, 1/2},
    },
  },
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, power_generator_cable = 1},
  sounds = node_sounds,
  
  --after_place_node = function(pos, placer, itemstack, pointed_thing)
  after_place_node = function(pos, placer, _, pointed_thing)
    if not Cable:after_place_tube(pos, placer, pointed_thing) then
      minetest.remove_node(pos)
      return true
    end
    return false
  end,
  --after_dig_node = function(pos, oldnode, oldmetadata, digger)
  after_dig_node = function(pos, oldnode, oldmetadata)
    Cable:after_dig_tube(pos, oldnode, oldmetadata)
  end,
  on_rotate = adaptation.screwdriver_mod.disallow, -- important!
  on_blast = gen_on_blast("power_generators:electric_cableS"),
})

minetest.register_node("power_generators:electric_cableA", {
  description = S("PG Electric Cable"),
  tiles = {
    -- up, down, right, left, back, front
    "power_generators_electric_cable.png",
    "power_generators_electric_cable_end.png",
    "power_generators_electric_cable.png",
    "power_generators_electric_cable.png",
    "power_generators_electric_cable.png",
    "power_generators_electric_cable_end.png",
  },
  
  paramtype2 = "facedir", -- important!
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-1/16, -1/2, -1/16,  1/16, 1/16,  1/16},
      {-1/16, -1/16, -1/2,  1/16, 1/16, -1/16},
    },
  },
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
      techage_trowel = 1, not_in_creative_inventory = 1},
  sounds = node_sounds,
  drop = "power_generators:electric_cableS",
  
  --after_dig_node = function(pos, oldnode, oldmetadata, digger)
  after_dig_node = function(pos, oldnode)
    Cable:after_dig_tube(pos, oldnode)
  end,
  on_rotate = adaptation.screwdriver_mod.disallow, -- important!
  on_blast = gen_on_blast("power_generators:electric_cableS"),
})

