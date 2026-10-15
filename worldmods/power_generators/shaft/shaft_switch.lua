--------------------------
-- Shaft Gearbox Switch --
--------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

local _shaft_sides = {"front", "back"}
local _shaft_types = {front="steel",back="steel"}

power_generators.shaft_switch = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:shaft_switch",
      node_name_active = "power_generators:shaft_switch_active",
      
      node_description = S("Shaft Gearbox Switch"),
      node_help = S("Can be greased.").."\n"..S("Can join/disjoin shaft."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      
      have_control = true,
      
      power_connect_sides = {"right","left"},
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _friction = 0.005,
      _I = 100,
      
      _rpm_deactivate = true,
      _qgrease_max = 2,
      _qgrease_eff = 1,
      
      sounds = {
        running2 = {
          sound = "power_generators_shaft_switch_running",
          sound_param = {max_hear_distance = 16, gain = 1},
          repeat_timer = 1,
          --update_sound = function(self, pos, meta, old_state, new_state, sound)
          update_sound = function(self, _, meta, _, _, sound)
            local rpm = meta:get_int("L")/meta:get_int("Isum")
            local new_sound = {
              sound = sound.sound,
              sound_param = table.copy(sound.sound_param),
            }
            if (meta:get_int("back_ratio")~=0) then
              new_sound.sound = "power_generators_gearbox_running"
            end
            new_sound.sound_param.gain = math.sqrt(rpm)*0.05
            new_sound.sound_param.pitch = 0.2+rpm*0.016
            return new_sound
          end,
        },
      },
    })

local shaft_switch = power_generators.shaft_switch

shaft_switch:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })

shaft_switch:control_data_register(
  {
    ["template_control"] = {
        --control_wait = function(self, control, pos, meta)
        control_wait = function(self)
          return false
        end,
        --on_punch = function(self, control, pos, node, puncher, pointed_thing)
        on_punch = function(self, _, pos)
          local meta = minetest.get_meta(pos)
          if meta:get_int("back_ratio")==0 then
            meta:set_int("back_ratio", 1)
          else
            meta:set_int("back_ratio", 0)
            meta:set_int("update", 1)
            local timer = minetest.get_node_timer(pos)
            if not timer:is_started() then
              timer:start(1)
            end
          end
        end,
        disable = {}
      },
  })

--------------
-- Formspec --
--------------

function shaft_switch:get_formspec()
  return "";
end

---------------
-- Callbacks --
---------------

power_generators.set_rpm_can_dig(shaft_switch)

function shaft_switch:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string(self.meta_infotext, self.node_description)
  
  meta:set_int("I", self._I)
  meta:set_int("Isum", self._I)
  meta:set_int("front_ratio", 1)
  meta:set_int("back_ratio", 1)
  self:call_on_construct(pos, meta)
end

--function shaft_switch:get_infotext(pos, meta, state)
function shaft_switch:get_infotext(_, meta, _)
  if meta:get_int("back_ratio")==0 then
    return self.node_description.." - "..S("off")
  else
    return self.node_description.." - "..S("on")
  end
end

function shaft_switch:cb_on_production(timer_step)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function shaft_switch:cb_waiting(pos, meta)
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
    {-0.125,-0.25,-0.375,0.125,-0.0625,0.375},
    {-0.1875,-0.1875,-0.375,-0.125,0.1875,0.375},
    {0.125,-0.1875,-0.375,0.1875,0.1875,0.375},
    {-0.4375,-0.125,-0.375,-0.375,-0.0625,0.5},
    {-0.25,-0.125,-0.375,-0.1875,0.125,0.375},
    {0.1875,-0.125,-0.375,0.25,0.125,0.375},
    {0.375,-0.125,-0.375,0.4375,-0.0625,0.5},
    {-0.4375,0.0625,-0.375,-0.375,0.125,0.5},
    {0.375,0.0625,-0.375,0.4375,0.125,0.5},
    {-0.125,0.125,-0.375,0.125,0.25,0.375},
    {-0.25,-0.1875,-0.1875,-0.1875,-0.125,0.1875},
    {0.1875,-0.1875,-0.1875,0.25,-0.125,0.1875},
    {-0.25,0.125,-0.1875,-0.1875,0.1875,0.1875},
    {0.1875,0.125,-0.1875,0.25,0.1875,0.1875},
    {-0.25,-0.25,-0.125,-0.125,-0.1875,0.125},
    {0.125,-0.25,-0.125,0.25,-0.1875,0.125},
    {-0.4375,-0.0625,-0.125,-0.375,0.0625,-0.0625},
    {0.375,-0.0625,-0.125,0.4375,0.0625,-0.0625},
    {-0.25,0.1875,-0.125,-0.125,0.25,0.125},
    {0.125,0.1875,-0.125,0.25,0.25,0.125},
    {0.0,0.25,-0.0625,0.0625,0.375,0.0},
    {0.0625,0.375,-0.0625,0.125,0.5,0.0},
    {-0.4375,-0.0625,0.0625,-0.375,0.0625,0.125},
    {0.375,-0.0625,0.0625,0.4375,0.0625,0.125},
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
    mesh = "power_generators_shaft_switch.obj",
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
        "power_generators_frame_steel.png",
    },
  }

local node_active = {
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_shaft_steel.png",
        "power_generators_body_steel.png",
        "power_generators_frame_steel.png",
    },
  }

shaft_switch:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------


