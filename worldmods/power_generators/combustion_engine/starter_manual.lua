-------------------------------
-- Combustion engine starter --
-------------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

local _shaft_sides = {"bottom"}
local _shaft_types = {bottom="starter"}

local starter_sound = {
    sound = "power_generators_starter_manual_running",
    sound_param = {max_hear_distance = 16, gain = 1, pitch = 1},
    --update_sound = function(self, pos, meta, old_state, new_state, sound)
    update_sound = function(self, _, meta, _, _, sound)
      local rpm = meta:get_int("L")/meta:get_int("Isum")
      local new_sound = {
        sound = sound.sound,
        sound_param = table.copy(sound.sound_param),
      }
      new_sound.sound_param.gain = rpm*0.2
      new_sound.sound_param.pitch = math.min(0.2+rpm*0.016, 1.1)
      --print("rpm: "..rpm)
      return new_sound
    end,
  }

power_generators.starter_manual = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:starter_manual",
      node_name_active = "power_generators:starter_manual_active",
      
      node_description = S("Combustion Engine Manual Starter"),
      node_help = S("Can be greased.").."\n"..S("Crank up starter by punching."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      
      power_connect_sides = {"front","back","right","left"},
      
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _friction = 0.5,
      _I = 1000,
      -- F of human etc 400 N, 250W
      -- 250 W = F*draha*1
      _maxT = 250*5,
      _coef = 1*5,
      
      _qgrease_max = 1.5,
      _qgrease_eff = 1,
      
      sounds = {
        running = starter_sound,
        nopower = starter_sound,
      },
    })

local starter_manual = power_generators.starter_manual

starter_manual:power_data_register(
  {
    ["punch_power"] = {
        run_speed = 1,
        disable = {}
      },
  })

--------------
-- Formspec --
--------------

--function starter_manual:get_formspec(meta, production_percent, consumption_percent)
function starter_manual:get_formspec()
  return "";
end

---------------
-- Callbacks --
---------------

power_generators.set_rpm_can_dig(starter_manual)

function starter_manual:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string(self.meta_infotext, self.node_description)
  
  meta:set_int("I", self._I)
  meta:set_int("Isum", self._I)
  meta:set_int("bottom_ratio", 100)
  meta:set_int("bottom_engine", 1)
  self:call_on_construct(pos, meta)
end

starter_manual.get_torque = power_generators.cesm_get_torque

function starter_manual:cb_on_production(timer_step)
  power_generators.update_shaft_supply(self, timer_step.pos, timer_step.meta, timer_step.speed)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function starter_manual:cb_waiting(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function starter_manual:cb_no_power(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function starter_manual:cb_deactivate(pos, meta)
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
    {-0.0625,-0.25,-0.0625,0.25,-0.1875,0.0},
    {0.1875,-0.1875,-0.0625,0.25,-0.125,0.0},
    {-0.0625,-0.25,0.0,0.0,-0.1875,0.4375},
    {-0.1875,-0.5,0.0625,0.1875,-0.25,0.375},
    {-0.1875,-0.25,0.0625,-0.0625,-0.0625,0.375},
    {0.0,-0.25,0.0625,0.1875,-0.0625,0.375},
    {-0.0625,-0.1875,0.0625,0.0,-0.0625,0.375},
    {-0.4375,-0.5,0.25,-0.3125,-0.0625,0.375},
    {0.3125,-0.5,0.25,0.4375,-0.125,0.375},
    {-0.4375,-0.25,0.375,-0.0625,-0.125,0.4375},
    {0.0,-0.25,0.375,0.4375,-0.125,0.4375},
    {-0.0625,-0.1875,0.375,0.0,-0.125,0.4375},
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
    mesh = "power_generators_ce_starter_manual.obj",
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
        "power_generators_body_steel.png",
        "power_generators_starter_manual_moving_parts.png",
    },
  }

local node_active = {
    mesh = "power_generators_ce_starter_manual_active.obj",
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_body_steel.png",
        {
          image = "power_generators_starter_manual_moving_parts_active.png",
          backface_culling = false,
          animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.5
          }
        }
    },
  }

starter_manual:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

