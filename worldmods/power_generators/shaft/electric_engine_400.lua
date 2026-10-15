
-------------------------
-- Combustion engine --
-------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

local _shaft_sides = {"front"}
local _shaft_types = {front="steel"}

power_generators.electric_engine_400 = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:electric_engine_400",
      node_name_active = "power_generators:electric_engine_400_active",
      
      node_description = S("Electric engine"),
      node_help = S("Use this for generate shaft power up to @1.", "80M").."\n"..S("Startup and Shutdown by punch.").."\n"..S("Can be greased."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      
      power_connect_sides = {"back","right","left"},
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _friction = 20,
      _maxT = 40000*2,
      -- maxP per step is (maxT/I)*I
      _maxP = 40000*1000*2,
      _limitRpm = 1000,
      _I = 60,
      
      _qgrease_max = 2,
      _qgrease_eff = 1,
      
      have_control = true,
      
      sounds = {
        active_running = {
          sound = "power_generators_electric_engine_startup",
          sound_param = {max_hear_distance = 24, gain = 1.41},
        },
        waiting_running = {
          sound = "power_generators_electric_engine_startup",
          sound_param = {max_hear_distance = 24, gain = 1.41},
        },
        nopower_running = {
          sound = "power_generators_electric_engine_startup",
          sound_param = {max_hear_distance = 24, gain = 1.41},
        },
        running = {
          sound = "power_generators_electric_engine_running",
          sound_param = {max_hear_distance = 24, gain = 1.41, loop = true},
          key = "running",
        },
        running_idle = {
          sound = "power_generators_electric_engine_shutdown",
          sound_param = {max_hear_distance = 24, gain = 1.41},
        },
        running_nopower = {
          sound = "power_generators_electric_engine_shutdown",
          sound_param = {max_hear_distance = 24, gain = 1.41},
        },
        running_waiting = {
          sound = "power_generators_electric_engine_shutdown",
          sound_param = {max_hear_distance = 24, gain = 1.41},
        },
      },
    })

local electric_engine_400 = power_generators.electric_engine_400

electric_engine_400:power_data_register(
  {
    ["no_power"] = {
        disable = {}
      },
    ["LV_power"] = {
        demand = 400,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["power_generators_electric_power"] = {
        demand = 400,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["elepower_power"] = {
        demand = 32,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["techage_electric_power"] = {
        demand = 160,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["factory_power"] = {
        demand = 20,
        run_speed = 1,
        disable = {"no_power"}
      },
  })
electric_engine_400:control_data_register(
  {
    ["punch_control"] = {
        power_off_on_deactivate = true,
      },
  })

electric_engine_400.node_help = S("Connect to power (@1).", electric_engine_400:get_power_help()).."\n"..electric_engine_400.node_help

--------------
-- Formspec --
--------------

function electric_engine_400:get_formspec()
  return ""
end

---------------
-- Callbacks --
---------------
power_generators.set_rpm_can_dig(electric_engine_400)

function electric_engine_400:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string(self.meta_infotext, self.node_description)
  
  meta:set_int("I", self._I)
  meta:set_int("Isum", self._I)
  meta:set_int("front_ratio", 1)
  meta:set_int("front_engine", 1)
  self:call_on_construct(pos, meta)
end

electric_engine_400.get_torque = power_generators.ee_get_torque

function electric_engine_400:cb_on_production(timer_step)
  power_generators.update_shaft_supply(self, timer_step.pos, timer_step.meta, timer_step.speed)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function electric_engine_400:cb_waiting(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function electric_engine_400:cb_no_power(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
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
    {-0.5,-0.5,-0.5,-0.375,0.5,-0.375},
    {0.375,-0.5,-0.5,0.5,0.5,-0.375},
    {-0.0625,-0.0625,-0.5,0.0625,0.0625,0.5},
    {-0.375,-0.125,-0.4375,0.375,-0.0625,-0.375},
    {-0.125,-0.0625,-0.4375,-0.0625,0.125,0.4375},
    {0.0625,-0.0625,-0.4375,0.125,0.125,0.4375},
    {-0.375,0.0625,-0.4375,-0.125,0.125,-0.375},
    {-0.0625,0.0625,-0.4375,0.0625,0.125,0.4375},
    {0.125,0.0625,-0.4375,0.375,0.125,-0.375},
    {-0.125,-0.3125,-0.375,0.125,-0.0625,0.375},
    {-0.1875,-0.25,-0.375,-0.125,0.25,0.375},
    {0.125,-0.25,-0.375,0.1875,0.25,0.375},
    {-0.25,-0.1875,-0.375,-0.1875,0.1875,0.375},
    {0.1875,-0.1875,-0.375,0.25,0.1875,0.375},
    {-0.4375,-0.125,-0.375,-0.375,-0.0625,0.5},
    {-0.3125,-0.125,-0.375,-0.25,0.125,0.375},
    {0.25,-0.125,-0.375,0.3125,0.125,0.375},
    {0.375,-0.125,-0.375,0.4375,-0.0625,0.5},
    {-0.4375,0.0625,-0.375,-0.375,0.125,0.5},
    {0.375,0.0625,-0.375,0.4375,0.125,0.5},
    {-0.125,0.125,-0.375,0.125,0.3125,0.375},
    {-0.4375,-0.0625,-0.125,-0.375,0.0625,0.125},
    {0.375,-0.0625,-0.125,0.4375,0.0625,0.125},
    {-0.5,-0.0625,-0.0625,-0.4375,0.0625,0.0625},
    {0.4375,-0.0625,-0.0625,0.5,0.0625,0.0625},
    {-0.375,0.0,0.0,-0.3125,0.0625,0.0625},
    {0.3125,0.0,0.0,0.375,0.0625,0.0625},
    {-0.5,-0.5,0.375,-0.375,-0.125,0.5},
    {0.375,-0.5,0.375,0.5,-0.125,0.5},
    {-0.5,-0.125,0.375,-0.4375,0.5,0.5},
    {-0.375,-0.125,0.375,0.375,-0.0625,0.4375},
    {0.4375,-0.125,0.375,0.5,0.5,0.5},
    {-0.4375,-0.0625,0.375,-0.375,0.0625,0.5},
    {0.375,-0.0625,0.375,0.4375,0.0625,0.5},
    {-0.375,0.0625,0.375,-0.125,0.125,0.4375},
    {0.125,0.0625,0.375,0.375,0.125,0.4375},
    {-0.4375,0.125,0.375,-0.375,0.5,0.5},
    {0.375,0.125,0.375,0.4375,0.5,0.5},
  },
}

local node_def = {
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2, shaft = 1, greasable = 1},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = node_sounds,
    drawtype = "mesh",
    mesh = "power_generators_shaft_ee_medium.obj",
    use_texture_alpha = "clip",
    collision_box = node_box,
    selection_box = node_box,
    
    _inspect_msg_func = power_generators.grease_inspect_msg,
    
    _shaft_sides = _shaft_sides,
    _shaft_types = _shaft_types,
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

electric_engine_400:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

