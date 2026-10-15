-------------------------
-- Combustion engine --
-------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

-- starting at 150 - 250 rpm (vznetovy) -> diesel
-- starting at 90 - 110 rpm (zazehovy)

-- (-0.0054*x*x+35.4931*x-1768.3608) , rpm > 100 to start
-- friction = friction*(rpm+2000000/(3*rpm+1000))

local _shaft_sides = {"front"}
local _shaft_types = {front="comb_engine"}

local engine_sound = {
    sound = "power_generators_combustion_engine_6c_running",
    sound_param = {max_hear_distance = 32, gain = 1, pitch = 1},
    --update_sound = function(self, pos, meta, old_state, new_state, sound)
    update_sound = function(self, _, meta, _, _, sound)
      local rpm = meta:get_int("L")/meta:get_int("Isum")
      local new_sound = {
        sound = sound.sound,
        sound_param = table.copy(sound.sound_param),
      }
      if rpm<300 then
        new_sound.sound = "power_generators_combustion_engine_6c_lowrpm"
        new_sound.sound_param.gain = rpm*0.04
        new_sound.sound_param.pitch = math.min(0.2+rpm*0.003, 1.1)
        --print("lowrpm sound "..dump(new_sound))
      else
        new_sound.sound_param.gain = 5+rpm*0.005
        new_sound.sound_param.pitch = math.min(0.2+rpm*0.00016, 1.1)
        --print("normal run sound "..dump(new_sound))
      end
      return new_sound
    end,
  }

power_generators.combustion_engine_6c = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:combustion_engine_6c",
      node_name_active = "power_generators:combustion_engine_6c_active",
      
      node_description = S("Combustion engine"),
      node_help = S("Use this for generate shaft power up to @1.", "323M").."\n"..S("Fuel supply open and close by punch.").."\n"..S("Can be greased.").."\n"..S("Place fuel tank on top."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      
      power_connect_sides = {"front","back","right","left"},
      
      have_control = true,
      
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _friction = 30,
      _I = 150,
      -- maxP per step is (maxT/I)*I
      _coef0 = -1768.3608*2.5,
      _coef1 = 35.4931*2.5,
      _coef2 = -0.0054*2.5,
      -- -0.0054*x*x+35.4931*x-1768.3608 , rpm > 200 to start
      -- up to T = 141 000
      _fuel_per_rpm = 6e-6,
      
      _qgrease_max = 2,
      _qgrease_eff = 1,
      
      sounds = {
        running = engine_sound,
        running_idle = {
          sound = "power_generators_combustion_engine_6c_shutdown",
          sound_param = {max_hear_distance = 32, gain = 1},
        },
        running_waiting = {
          sound = "power_generators_combustion_engine_6c_shutdown",
          sound_param = {max_hear_distance = 32, gain = 1},
        },
      },
    })

local combustion_engine_6c = power_generators.combustion_engine_6c

combustion_engine_6c:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })
combustion_engine_6c:control_data_register(
  {
    ["punch_control"] = {
        power_off_on_deactivate = true,
      },
  })

--------------
-- Formspec --
--------------

--function combustion_engine_6c:get_formspec(meta, production_percent, consumption_percent)
function combustion_engine_6c:get_formspec(meta, _, _)
  local throttle = meta:get_float("throttle")
  local bar = "scrollbar[2.25,1;1,6;vertical;throttle;"..(math.floor(1400-throttle*1000)).."]";
  
  
  local formspec =  "formspec_version[3]" .. "size[5.75,8.5]" ..
                    "background[-1.25,-1.25;8,10;appliances_appliance_formspec.png]" ..
                    "scrollbaroptions[min=200;max=1200;smallstep=1;largestep=20]" ..
                    bar ..
                    "style_type[label;textcolor=black]" ..
                    "label[2,8;"..minetest.formspec_escape(S("Throttle @1%", math.round(throttle*100))).."]";
  return formspec;
end

function combustion_engine_6c:cb_on_receive_fields(pos, formname, fields, sender)
    if fields.throttle then
      local exp = minetest.explode_scrollbar_event(fields.throttle)
      local meta = minetest.get_meta(pos)
      meta:set_float("throttle", (1400-exp.value)/1000)
    end
    if fields.quit then
      local meta = minetest.get_meta(pos)
      meta:set_string("formspec", combustion_engine_6c:get_formspec(meta, 0, 0))
    end
  self:call_on_receive_fields(pos, formname, fields, sender)
end

---------------
-- Callbacks --
---------------

power_generators.set_rpm_can_dig(combustion_engine_6c)

function combustion_engine_6c:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_int("I", self._I)
  meta:set_int("Isum", self._I)
  meta:set_int("front_ratio", 1)
  meta:set_int("front_engine", 0)
  meta:set_float("throttle", 0.2)
  
  meta:set_string(self.meta_infotext, self.node_description)
  meta:set_string("formspec", self:get_formspec(meta, 0, 0))
  
  self:call_on_construct(pos, meta)
end

combustion_engine_6c.get_torque = power_generators.ce_get_torque

function combustion_engine_6c:cb_on_production(timer_step)
  power_generators.update_shaft_supply(self, timer_step.pos, timer_step.meta, timer_step.speed)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function combustion_engine_6c:cb_waiting(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function combustion_engine_6c:cb_no_power(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function combustion_engine_6c:cb_deactivate(pos, meta)
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
    {-0.375,-0.4375,-0.5,0.375,-0.3125,-0.375},
    {-0.0625,-0.3125,-0.5,0.0625,-0.0625,0.375},
    {-0.125,-0.25,-0.5,-0.0625,-0.125,0.375},
    {0.0625,-0.25,-0.5,0.125,-0.125,0.375},
    {-0.375,0.0625,-0.5,0.375,0.1875,-0.375},
    {-0.125,-0.5,-0.375,0.125,-0.3125,0.375},
    {-0.5,-0.4375,-0.375,-0.375,-0.3125,0.5},
    {-0.1875,-0.4375,-0.375,-0.125,-0.0625,0.375},
    {0.125,-0.4375,-0.375,0.1875,-0.0625,0.375},
    {0.375,-0.4375,-0.375,0.5,-0.3125,0.5},
    {-0.25,-0.375,-0.375,-0.1875,-0.125,0.375},
    {0.1875,-0.375,-0.375,0.25,-0.125,0.375},
    {-0.125,-0.3125,-0.375,-0.0625,-0.25,0.375},
    {0.0625,-0.3125,-0.375,0.125,-0.25,0.375},
    {-0.125,-0.125,-0.375,-0.0625,0.0,0.375},
    {0.0625,-0.125,-0.375,0.125,0.0,0.375},
    {-0.0625,-0.0625,-0.375,0.0625,0.0,0.375},
    {-0.5,0.0625,-0.375,-0.375,0.1875,0.5},
    {0.375,0.0625,-0.375,0.5,0.1875,0.5},
    {-0.0625,0.125,-0.375,0.0625,0.1875,0.5},
    {-0.125,0.1875,-0.375,-0.0625,0.3125,0.375},
    {0.0625,0.1875,-0.375,0.125,0.3125,0.375},
    {-0.0625,0.3125,-0.375,0.0625,0.375,0.1875},
    {-0.3125,-0.1875,-0.3125,-0.25,0.375,0.3125},
    {0.25,-0.1875,-0.3125,0.3125,0.375,0.1875},
    {-0.25,-0.125,-0.3125,-0.1875,0.375,0.3125},
    {0.1875,-0.125,-0.3125,0.25,0.375,0.3125},
    {-0.3125,-0.3125,-0.25,-0.25,-0.1875,-0.125},
    {0.25,-0.3125,-0.25,0.3125,-0.1875,-0.125},
    {-0.375,-0.1875,-0.25,-0.3125,0.375,-0.125},
    {0.3125,-0.1875,-0.25,0.375,0.375,-0.125},
    {-0.1875,-0.0625,-0.25,-0.125,0.375,-0.125},
    {0.125,-0.0625,-0.25,0.1875,0.375,-0.125},
    {-0.0625,0.0,-0.25,0.0625,0.125,0.375},
    {-0.3125,0.375,-0.25,-0.1875,0.4375,-0.125},
    {0.1875,0.375,-0.25,0.3125,0.4375,-0.125},
    {-0.125,0.0,-0.1875,-0.0625,0.125,0.375},
    {0.0625,0.0,-0.1875,0.125,0.125,-0.125},
    {-0.4375,0.3125,-0.1875,-0.375,0.375,0.25},
    {-0.125,0.3125,-0.1875,-0.0625,0.375,0.3125},
    {0.0625,0.3125,-0.1875,0.125,0.375,0.3125},
    {0.375,0.3125,-0.1875,0.4375,0.375,0.25},
    {0.0625,0.0625,-0.125,0.125,0.125,0.5},
    {-0.3125,-0.3125,-0.0625,-0.25,-0.1875,0.0625},
    {0.25,-0.3125,-0.0625,0.3125,-0.1875,0.0625},
    {-0.375,-0.1875,-0.0625,-0.3125,0.375,0.0625},
    {0.3125,-0.1875,-0.0625,0.375,0.375,0.0625},
    {-0.1875,-0.0625,-0.0625,-0.125,0.375,0.0625},
    {0.125,-0.0625,-0.0625,0.1875,0.375,0.0625},
    {0.0625,0.0,-0.0625,0.125,0.0625,0.0625},
    {-0.3125,0.375,-0.0625,-0.1875,0.4375,0.0625},
    {0.1875,0.375,-0.0625,0.3125,0.4375,0.0625},
    {-0.125,0.125,0.0625,-0.0625,0.1875,0.5},
    {0.0625,0.125,0.0625,0.125,0.1875,0.5},
    {-0.0625,0.1875,0.0625,0.0625,0.3125,0.375},
    {-0.3125,-0.3125,0.125,-0.25,-0.1875,0.25},
    {0.25,-0.3125,0.125,0.3125,-0.1875,0.25},
    {-0.375,-0.1875,0.125,-0.3125,0.375,0.25},
    {0.3125,-0.1875,0.125,0.375,0.375,0.25},
    {-0.1875,-0.0625,0.125,-0.125,0.375,0.25},
    {0.125,-0.0625,0.125,0.1875,0.375,0.25},
    {0.0625,0.0,0.125,0.125,0.0625,0.375},
    {-0.3125,0.375,0.125,-0.1875,0.4375,0.25},
    {-0.0625,0.375,0.125,0.0625,0.5,0.1875},
    {0.1875,0.375,0.125,0.3125,0.4375,0.25},
    {0.25,-0.125,0.1875,0.3125,0.375,0.3125},
    {-0.125,0.375,0.1875,-0.0625,0.5,0.3125},
    {0.0625,0.375,0.1875,0.125,0.5,0.3125},
    {0.25,-0.1875,0.25,0.3125,-0.125,0.3125},
    {-0.375,0.3125,0.25,-0.3125,0.375,0.3125},
    {0.3125,0.3125,0.25,0.375,0.375,0.3125},
    {-0.1875,0.25,0.3125,-0.125,0.3125,0.375},
    {0.125,0.25,0.3125,0.1875,0.3125,0.375},
    {-0.3125,0.3125,0.3125,-0.1875,0.375,0.375},
    {-0.0625,0.3125,0.3125,0.0625,0.5,0.375},
    {0.1875,0.3125,0.3125,0.3125,0.375,0.375},
    {-0.5,-0.5,0.375,-0.375,-0.4375,0.5},
    {0.375,-0.5,0.375,0.5,-0.4375,0.5},
    {-0.375,-0.4375,0.375,0.375,-0.3125,0.5},
    {-0.5,-0.3125,0.375,-0.375,0.0625,0.5},
    {0.375,-0.3125,0.375,0.5,0.0625,0.5},
    {-0.375,0.0625,0.375,0.0625,0.125,0.5},
    {0.125,0.0625,0.375,0.375,0.1875,0.5},
    {-0.375,0.125,0.375,-0.125,0.1875,0.5},
    {-0.5,0.1875,0.375,-0.375,0.5,0.5},
    {-0.125,0.1875,0.375,-0.0625,0.25,0.5},
    {0.0625,0.1875,0.375,0.125,0.25,0.5},
    {0.375,0.1875,0.375,0.5,0.5,0.5},
    {-0.0625,0.25,0.375,0.0625,0.3125,0.5},
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
    mesh = "power_generators_ce_6c.obj",
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
        "power_generators_ce_pipes.png",
    },
  }

local node_active = {
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_shaft_steel.png",
        "power_generators_body_steel.png",
        "power_generators_ce_pipes.png",
    },
  }

combustion_engine_6c:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

