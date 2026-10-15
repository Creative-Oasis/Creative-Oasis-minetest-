-------------------------------
-- Combustion engine gearbox --
-------------------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

local _shaft_sides = {"front", "back", "top"}
local _shaft_types = {front="steel",back="comb_engine",top="starter"}

power_generators.ce_gearbox = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:gearbox",
      node_name_active = "power_generators:gearbox_active",
      
      node_description = S("Gearbox for Combustion Engine with External Starter"),
      node_help = S("Can be greased.").."\n"..S("Change gear by punch (neutral/shaft/starter).").."\n"..S("Place starter on top."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      
      power_connect_sides = {"front"},
      
      have_control = true,
      
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _shaft_side = "front",
      _starter_side = "top",
      _engine_side = "back",
      _friction = 5,
      _I = 90,
      
      _qgrease_max = 2,
      _qgrease_eff = 1,
      
      sounds = {
        running = {
          sound = "power_generators_gearbox_running",
          sound_param = {max_hear_distance = 32, gain = 2},
          --update_sound = function(self, pos, meta, old_state, new_state, sound)
          update_sound = function(self, _, meta, _, _, sound)
            local rpm = meta:get_int("L")/meta:get_int("Isum")
            local new_sound = {
              sound = sound.sound,
              sound_param = table.copy(sound.sound_param),
            }
            new_sound.sound_param.gain = rpm*0.0008
            return new_sound
          end,
        },
      },
    })

local ce_gearbox = power_generators.ce_gearbox

ce_gearbox:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })
local next_shifting = {
  ["starter"] = "neutral",
  ["neutral"] = "shaft",
  ["shaft"] = "starter",
}
ce_gearbox:control_data_register(
  {
    ["template_control"] = {
        --on_punch = function(self, control, pos, node, puncher, pointed_thing)
        on_punch = function(self, _, pos, node)
          local meta = minetest.get_meta(pos)
          local shifting = meta:get_string("shifting")
          shifting = next_shifting[shifting]
          if shifting == "starter" then
            if meta:get_float("rpm")>0 then
              -- next to neutral
              shifting = next_shifting[shifting]
            end
          end
          meta:set_string("shifting", shifting)
          power_generators.ce_gearbox_shifting(self, pos, node, meta)
        end,
      },
  })

--------------
-- Formspec --
--------------

--function ce_gearbox:get_formspec(meta, production_percent, consumption_percent)
function ce_gearbox:get_formspec(_meta, _, consumption_percent)
  local progress;
  
  progress = "image[3.6,0.9;5.5,0.95;appliances_consumption_progress_bar.png^[transformR270]]";
  if consumption_percent then
    progress = "image[3.6,0.9;5.5,0.95;appliances_consumption_progress_bar.png^[lowpart:" ..
            (consumption_percent) ..
            ":appliances_consumption_progress_bar_full.png^[transformR270]]";
  end
  
  
  
  local formspec =  "size[12.75,8.5]" ..
                    "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                    progress..
                    self:get_player_inv() ..
                    self:get_formspec_list("context", self.use_stack, 2, 0.8, 1, 1)..
                    self:get_formspec_list("context", self.output_stack, 9.75, 0.25, 2, 2)..
                    "listring[current_player;main]" ..
                    "listring[context;"..self.use_stack.."]" ..
                    "listring[current_player;main]" ..
                    "listring[context;"..self.output_stack.."]" ..
                    "listring[current_player;main]";
  return formspec;
end

---------------
-- Callbacks --
---------------

power_generators.set_rpm_can_dig(ce_gearbox)

local shifting_text = {
  ["starter"] = S("Starter"),
  ["neutral"] = S("Neutral"),
  ["shaft"] = S("Shaft"),
}

--function ce_gearbox:get_infotext(pos, meta, state)
function ce_gearbox:get_infotext(_, meta)
  return self.node_description.." - "..shifting_text[meta:get_string("shifting")]
end

function ce_gearbox:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string(self.meta_infotext, self.node_description)
  
  meta:set_int("I", self._I)
  meta:set_int("Isum", self._I)
  meta:set_int("front_ratio", 0)
  meta:set_int("back_ratio", 1)
  meta:set_int("top_ratio", 0)
  meta:set_string("shifting", "neutral")
  self:call_on_construct(pos, meta)
end

function ce_gearbox:cb_on_production(timer_step)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function ce_gearbox:cb_waiting(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function ce_gearbox:cb_no_power(pos, meta)
  power_generators.shaft_step(self, pos, meta, nil)
end

function ce_gearbox:cb_deactivate(pos, meta)
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
    {-0.0625,-0.0625,-0.5,0.0625,0.0625,0.4375},
    {-0.5,-0.5,-0.4375,-0.375,0.125,-0.3125},
    {0.375,-0.5,-0.4375,0.5,0.125,-0.3125},
    {-0.375,-0.375,-0.4375,0.375,-0.25,-0.375},
    {-0.375,0.0625,-0.4375,0.375,0.1875,0.125},
    {-0.4375,0.125,-0.4375,-0.375,0.1875,-0.3125},
    {0.375,0.125,-0.4375,0.4375,0.1875,-0.3125},
    {-0.1875,-0.5,-0.375,0.1875,-0.0625,0.375},
    {-0.25,-0.4375,-0.375,-0.1875,0.0625,0.375},
    {0.1875,-0.4375,-0.375,0.25,0.0625,0.375},
    {-0.3125,-0.375,-0.375,-0.25,0.0625,0.125},
    {0.25,-0.375,-0.375,0.3125,0.0625,0.125},
    {-0.375,-0.1875,-0.375,-0.3125,0.0625,0.125},
    {0.3125,-0.1875,-0.375,0.375,0.0625,0.125},
    {-0.1875,-0.0625,-0.375,-0.0625,0.0625,0.4375},
    {0.0625,-0.0625,-0.375,0.1875,0.0625,0.4375},
    {-0.3125,0.1875,-0.375,0.3125,0.25,0.125},
    {-0.25,0.25,-0.375,0.25,0.3125,0.125},
    {-0.1875,0.3125,-0.375,0.1875,0.375,0.375},
    {-0.4375,-0.1875,-0.3125,-0.375,-0.0625,0.375},
    {0.375,-0.1875,-0.3125,0.4375,-0.0625,0.375},
    {-0.3125,-0.375,0.125,-0.25,0.0,0.375},
    {0.25,-0.375,0.125,0.3125,0.0,0.375},
    {-0.1875,0.0625,0.125,0.1875,0.3125,0.375},
    {-0.1875,0.375,0.125,0.1875,0.5,0.375},
    {-0.4375,-0.5,0.25,-0.3125,-0.1875,0.375},
    {0.3125,-0.5,0.25,0.4375,-0.1875,0.375},
    {-0.375,-0.1875,0.25,-0.3125,0.5,0.375},
    {0.3125,-0.1875,0.25,0.375,0.5,0.375},
    {-0.4375,-0.0625,0.25,-0.375,0.5,0.375},
    {0.375,-0.0625,0.25,0.4375,0.5,0.375},
    {-0.0625,-0.3125,0.375,0.0625,-0.0625,0.5},
    {-0.125,-0.25,0.375,-0.0625,-0.125,0.5},
    {0.0625,-0.25,0.375,0.125,-0.125,0.5},
    {-0.4375,-0.0625,0.375,-0.1875,0.0625,0.4375},
    {0.1875,-0.0625,0.375,0.4375,0.0625,0.4375},
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
    mesh = "power_generators_ce_gearbox.obj",
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
        "power_generators_body_steel.png",
    },
  }

local node_active = {
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_shaft_steel.png",
        "power_generators_body_steel.png",
        "power_generators_body_steel.png",
    },
  }

ce_gearbox:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

