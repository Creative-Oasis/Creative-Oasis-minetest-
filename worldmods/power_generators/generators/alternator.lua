
-------------------------
-- Alternator --
-------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;
local Cable = power_generators.electric_cable

power_generators.alternator = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:alternator",
      node_name_active = "power_generators:alternator_active",
      
      node_description = S("Alternator"),
      node_help = S("Use this for generate energy PG EU depend on rpm."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      
      power_connect_sides = {"back"},
      out_power_connect_sides = {"left", "right", "front"},
      
      _shaft_types = {back="steel"},
      
      sounds = {
        active_running = {
          sound = "power_generators_alternator_startup",
          sound_param = {max_hear_distance = 32, gain = 1},
          repeat_timer = 3,
        },
        waiting_running = {
          sound = "power_generators_alternator_startup",
          sound_param = {max_hear_distance = 32, gain = 1},
          repeat_timer = 3,
        },
        running = {
          sound = "power_generators_alternator_running",
          sound_param = {max_hear_distance = 32, gain = 1},
          repeat_timer = 1,
        },
        running_idle = {
          sound = "power_generators_alternator_shutdown",
          sound_param = {max_hear_distance = 32, gain = 1},
        },
        running_nopower = {
          sound = "power_generators_alternator_shutdown",
          sound_param = {max_hear_distance = 32, gain = 1},
        },
        running_waiting = {
          sound = "power_generators_alternator_shutdown",
          sound_param = {max_hear_distance = 32, gain = 1},
        },
      },
    })

local alternator = power_generators.alternator

alternator:power_data_register(
  {
    ["no_power"] = {
    },
    ["power_generators_shaft_power"] = {
        -- 60% efficiency
        run_speed = 1,
        friction = 25,
        I = 25,
        qgrease_max = 2,
        qgrease_eff = 1,
        rpm_deactivate = true,
        demand = 1, -- min rpm to do something
        disable = {"no_power"}
      },
  })

--------------
-- Formspec --
--------------

--function alternator:get_formspec(meta, production_percent, consumption_percent)
function alternator:get_formspec()
  return ""
end

---------------
-- Callbacks --
---------------


function alternator:cb_on_production(timer_step)
  local meta = timer_step.meta
  local I = meta:get_int("I");
  local L = meta:get_int("L")
  local rpm = L/I
  local use_usage = {
    --generator_output = math.floor(rpm*0.24), -- idela greaser, etc 60% eff for 400 engine at 1000 rpm
    generator_output = math.floor(rpm*0.3), -- reflect not ideal greasers, so some reserve... for ideal greaser make 75% eff at 1000 rpm for 400 engine
  }
  if (rpm<250) then
    use_usage.generator_output = use_usage.generator_output*rpm/250
  end
  power_generators.update_generator_supply(self.out_power_connect_sides, timer_step.pos, use_usage)
end

--function alternator:cb_waiting(pos, meta)
function alternator:cb_waiting(pos)
  power_generators.update_generator_supply(self.out_power_connect_sides, pos, nil)
end

--function alternator:cb_deactivate(pos, meta)
function alternator:cb_deactivate(pos)
  power_generators.update_generator_supply(self.out_power_connect_sides, pos, nil)
end

----------
-- Node --
----------

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
  
-- node box {x=0, y=0, z=0}
local node_box = {
  type = "fixed",
  fixed = {
    {-0.0625,-0.0625,-0.5,0.0625,0.0625,-0.4375},
    {-0.3125,-0.5,-0.4375,0.3125,-0.4375,-0.375},
    {-0.375,-0.4375,-0.4375,-0.3125,0.125,-0.375},
    {0.3125,-0.4375,-0.4375,0.375,0.125,-0.375},
    {0.0,-0.0625,-0.4375,0.0625,0.0625,0.5},
    {-0.3125,0.0,-0.4375,0.0,0.0625,0.4375},
    {0.0625,0.0,-0.4375,0.3125,0.0625,0.4375},
    {-0.3125,0.125,-0.4375,0.3125,0.1875,-0.375},
    {-0.375,-0.5,-0.375,-0.3125,-0.4375,0.375},
    {0.3125,-0.5,-0.375,0.375,-0.4375,0.375},
    {0.0625,-0.4375,-0.375,0.25,-0.125,-0.3125},
    {-0.1875,-0.375,-0.375,-0.0625,-0.25,0.4375},
    {0.25,-0.1875,-0.375,0.375,-0.125,-0.3125},
    {0.0,-0.125,-0.375,0.0625,-0.0625,-0.25},
    {-0.375,0.0,-0.375,-0.3125,0.0625,0.4375},
    {0.3125,0.0,-0.375,0.375,0.0625,0.4375},
    {-0.25,-0.4375,-0.3125,0.0,-0.375,0.0},
    {0.0625,-0.4375,-0.3125,0.25,-0.1875,-0.25},
    {-0.25,-0.375,-0.3125,-0.1875,-0.1875,0.0},
    {-0.0625,-0.375,-0.3125,0.0,0.0,-0.25},
    {-0.1875,-0.25,-0.3125,-0.0625,-0.1875,0.375},
    {-0.25,-0.0625,-0.3125,-0.0625,0.0,0.3125},
    {0.0625,-0.0625,-0.3125,0.25,0.0,0.3125},
    {-0.25,0.0625,-0.3125,0.25,0.125,0.3125},
    {-0.375,-0.4375,-0.25,-0.25,-0.375,-0.1875},
    {-0.0625,-0.375,-0.25,0.0,-0.125,0.0},
    {-0.0625,-0.0625,-0.25,0.0,0.0,0.3125},
    {-0.3125,0.0625,-0.25,-0.25,0.125,0.25},
    {0.25,0.0625,-0.25,0.3125,0.125,0.25},
    {-0.25,0.125,-0.25,0.25,0.1875,0.25},
    {0.0625,-0.4375,-0.1875,0.375,-0.375,-0.125},
    {0.0,-0.375,-0.1875,0.1875,-0.3125,0.0},
    {0.0625,-0.3125,-0.1875,0.25,-0.25,0.0},
    {0.125,-0.25,-0.1875,0.1875,-0.1875,0.0},
    {-0.125,-0.1875,-0.1875,-0.0625,-0.0625,-0.125},
    {-0.0625,0.1875,-0.1875,0.0625,0.25,-0.0625},
    {0.0,-0.4375,-0.125,0.1875,-0.375,-0.0625},
    {0.0,-0.3125,-0.125,0.0625,-0.25,-0.0625},
    {-0.375,-0.4375,-0.0625,-0.25,-0.375,0.0},
    {0.0625,-0.4375,-0.0625,0.375,-0.375,0.0},
    {0.0625,-0.25,-0.0625,0.125,-0.125,0.0},
    {-0.3125,-0.1875,-0.0625,-0.0625,-0.125,0.0},
    {0.0,-0.1875,-0.0625,0.0625,-0.125,0.0},
    {0.125,-0.1875,-0.0625,0.3125,-0.125,0.0},
    {-0.3125,-0.125,-0.0625,-0.25,0.0,0.0},
    {0.25,-0.125,-0.0625,0.3125,0.0,0.0},
    {-0.5,-0.0625,-0.0625,-0.3125,0.0,0.0},
    {0.3125,-0.0625,-0.0625,0.5,0.0,0.0},
    {-0.5,0.0,-0.0625,-0.375,0.0625,0.0},
    {0.375,0.0,-0.0625,0.5,0.0625,0.0},
    {-0.1875,-0.4375,0.0,-0.0625,-0.375,0.375},
    {-0.25,-0.375,0.0,-0.1875,-0.25,0.375},
    {-0.0625,-0.375,0.0,0.0,-0.25,0.375},
    {0.125,-0.3125,0.0,0.1875,-0.25,0.375},
    {0.0625,-0.25,0.0,0.125,-0.1875,0.375},
    {-0.5,-0.0625,0.0,-0.4375,0.0625,0.0625},
    {0.4375,-0.0625,0.0,0.5,0.0625,0.0625},
    {-0.375,-0.4375,0.0625,-0.1875,-0.375,0.125},
    {0.125,-0.4375,0.0625,0.375,-0.375,0.125},
    {0.0625,-0.375,0.0625,0.25,-0.3125,0.375},
    {0.0625,-0.3125,0.0625,0.125,-0.25,0.375},
    {0.1875,-0.3125,0.0625,0.25,-0.25,0.375},
    {0.125,-0.25,0.0625,0.1875,-0.1875,0.375},
    {0.125,-0.4375,0.125,0.1875,-0.375,0.375},
    {-0.1875,-0.5,0.3125,-0.0625,-0.4375,0.4375},
    {0.125,-0.5,0.3125,0.1875,-0.4375,0.4375},
    {-0.375,-0.25,0.3125,-0.1875,-0.1875,0.375},
    {0.0,-0.25,0.3125,0.0625,-0.0625,0.375},
    {0.1875,-0.25,0.3125,0.375,-0.1875,0.375},
    {-0.3125,-0.5,0.375,-0.1875,-0.4375,0.4375},
    {-0.0625,-0.5,0.375,0.125,-0.4375,0.4375},
    {0.1875,-0.5,0.375,0.3125,-0.4375,0.4375},
    {-0.375,-0.4375,0.375,-0.3125,0.0,0.4375},
    {0.3125,-0.4375,0.375,0.375,0.0,0.4375},
    {-0.375,0.0625,0.375,-0.3125,0.125,0.4375},
    {0.3125,0.0625,0.375,0.375,0.125,0.4375},
    {-0.3125,0.125,0.375,0.3125,0.1875,0.4375},
    {-0.0625,-0.0625,0.4375,0.0,0.0625,0.5},
  },
}

local node_def = {
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2, power_generator = 1},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = node_sounds,
    drawtype = "mesh",
    mesh = "power_generators_alternator.obj",
    use_texture_alpha = "clip",
    collision_box = node_box,
    selection_box = node_box,
    
    _inspect_msg_func = power_generators.grease_inspect_msg,
 }

local node_inactive = {
    tiles = {
      "power_generators_frame_steel.png",
      "power_generators_shaft_steel.png",
      "power_generators_body_steel.png",
      "power_generators_electric_cable.png",
    },
  }

local node_active = {
    tiles = {
      "power_generators_frame_steel.png",
      "power_generators_shaft_steel.png",
      "power_generators_body_steel.png",
      "power_generators_electric_cable.png",
    },
  }

alternator:register_nodes(node_def, node_inactive, node_active)

Cable:add_secondary_node_names({alternator.node_name_active, alternator.node_name_inactive})
--Cable:add_special_node_names({name})
Cable:set_valid_sides(alternator.node_name_active, {"R", "L", "F"})
Cable:set_valid_sides(alternator.node_name_inactive, {"R", "L", "F"})

-------------------------
-- Recipe Registration --
-------------------------

