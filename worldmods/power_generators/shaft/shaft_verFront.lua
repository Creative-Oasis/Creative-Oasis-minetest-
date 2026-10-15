--------------------------
-- Shaft Vertical-Front --
--------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

local _shaft_sides = {"top","bottom", "front"}
local _shaft_types = {front="steel",top="steel",bottom="steel"}

power_generators.shaft_verFront = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:shaft_verFront",
      node_name_active = "power_generators:shaft_verFront_active",
      
      node_description = S("Shaft Vertical With Front Branch"),
      node_help = S("Can be greased."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      
      power_connect_sides = {"right","left"},
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _friction = 1,
      _I = 10,
      
      _rpm_deactivate = true,
      _qgrease_max = 3,
      _qgrease_eff = 2,
      
      sounds = {
        active_running = {
          sound = "power_generators_shaft_verFront_running",
          sound_param = {max_hear_distance = 16, gain = 1},
          repeat_timer = 3,
        },
        waiting_running = {
          sound = "power_generators_shaft_verFront_running",
          sound_param = {max_hear_distance = 16, gain = 1},
          repeat_timer = 3,
        },
        running = {
          sound = "power_generators_shaft_verFront_running",
          sound_param = {max_hear_distance = 16, gain = 1},
          repeat_timer = 1,
        },
      },
    })

local shaft_verFront = power_generators.shaft_verFront

shaft_verFront:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })

--------------
-- Formspec --
--------------

function shaft_verFront:get_formspec()
  return "";
end

---------------
-- Callbacks --
---------------

power_generators.set_rpm_can_dig(shaft_verFront)

function shaft_verFront:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string(self.meta_infotext, self.node_description)
  
  meta:set_int("I", self._I)
  meta:set_int("Isum", self._I)
  meta:set_int("bottom_ratio", 1)
  meta:set_int("top_ratio", 1)
  meta:set_int("front_ratio", 1)
  self:call_on_construct(pos, meta)
end

--function shaft_verFront:get_infotext(pos, meta, state)
function shaft_verFront:get_infotext(_, _, state)
  if state=="running" then
    return self.node_description.." - "..S("working")
  else
    return self.node_description.." - "..appliances.state_infotexts[state]
  end
end

function shaft_verFront:cb_on_production(timer_step)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function shaft_verFront:cb_waiting(pos, meta)
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
    {-0.0625,-0.0625,-0.5,0.0625,0.0625,0.375},
    {-0.375,-0.125,-0.4375,0.375,-0.0625,-0.375},
    {-0.125,-0.0625,-0.4375,-0.0625,0.125,0.25},
    {0.0625,-0.0625,-0.4375,0.125,0.125,0.25},
    {-0.375,0.0625,-0.4375,-0.125,0.125,-0.375},
    {-0.0625,0.0625,-0.4375,0.0625,0.125,0.4375},
    {0.125,0.0625,-0.4375,0.375,0.125,-0.375},
    {-0.125,-0.25,-0.375,0.125,-0.0625,0.25},
    {-0.1875,-0.1875,-0.375,-0.125,0.1875,0.25},
    {0.125,-0.1875,-0.375,0.1875,0.1875,0.25},
    {-0.4375,-0.125,-0.375,-0.375,-0.0625,0.5},
    {-0.25,-0.125,-0.375,-0.1875,0.125,0.25},
    {0.1875,-0.125,-0.375,0.25,0.125,0.25},
    {0.375,-0.125,-0.375,0.4375,-0.0625,0.5},
    {-0.4375,0.0625,-0.375,-0.375,0.125,0.5},
    {0.375,0.0625,-0.375,0.4375,0.125,0.5},
    {-0.125,0.125,-0.375,0.125,0.25,0.25},
    {-0.125,-0.375,-0.25,0.125,-0.25,0.25},
    {-0.125,0.25,-0.25,0.125,0.375,0.25},
    {-0.1875,-0.375,-0.1875,-0.125,-0.1875,0.1875},
    {0.125,-0.375,-0.1875,0.1875,-0.1875,0.1875},
    {-0.1875,0.1875,-0.1875,-0.125,0.375,0.1875},
    {0.125,0.1875,-0.1875,0.1875,0.375,0.1875},
    {-0.25,-0.375,-0.125,-0.1875,-0.125,0.125},
    {0.1875,-0.375,-0.125,0.25,-0.125,0.125},
    {-0.4375,-0.0625,-0.125,-0.375,0.0625,-0.0625},
    {0.375,-0.0625,-0.125,0.4375,0.0625,-0.0625},
    {-0.25,0.125,-0.125,-0.1875,0.375,0.125},
    {0.1875,0.125,-0.125,0.25,0.375,0.125},
    {-0.0625,-0.5,-0.0625,0.0625,-0.375,0.0625},
    {-0.0625,0.375,-0.0625,0.0625,0.5,0.0625},
    {-0.4375,-0.0625,0.0625,-0.375,0.0625,0.125},
    {0.375,-0.0625,0.0625,0.4375,0.0625,0.125},
    {-0.0625,-0.125,0.25,0.0625,-0.0625,0.4375},
    {-0.125,-0.0625,0.25,-0.0625,0.0625,0.4375},
    {0.0625,-0.0625,0.25,0.125,0.0625,0.4375},
    {-0.5,-0.5,0.375,-0.375,-0.125,0.5},
    {0.375,-0.5,0.375,0.5,-0.125,0.5},
    {-0.5,-0.125,0.375,-0.4375,0.5,0.5},
    {-0.375,-0.125,0.375,-0.0625,-0.0625,0.4375},
    {0.0625,-0.125,0.375,0.375,-0.0625,0.4375},
    {0.4375,-0.125,0.375,0.5,0.5,0.5},
    {-0.4375,-0.0625,0.375,-0.375,0.0625,0.5},
    {0.375,-0.0625,0.375,0.4375,0.0625,0.5},
    {-0.375,0.0625,0.375,-0.0625,0.125,0.4375},
    {0.0625,0.0625,0.375,0.375,0.125,0.4375},
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
    mesh = "power_generators_shaft_verFront.obj",
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
    },
  }

local node_active = {
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_shaft_steel.png",
        "power_generators_body_steel.png",
    },
  }

shaft_verFront:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------


