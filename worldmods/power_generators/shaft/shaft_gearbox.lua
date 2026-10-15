-------------------
-- Shaft Gearbox --
-------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

local _shaft_sides = {"front", "back"}
local _shaft_types = {front="steel",back="steel"}

power_generators.shaft_gearbox = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:shaft_gearbox",
      node_name_active = "power_generators:shaft_gearbox_active",
      
      node_description = S("Shaft Gearbox"),
      node_help = S("Can be greased.").."\n"..S("Put/take gears to set gear ratio."),
      
      input_stack_size = 2,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 0,
      
      power_connect_sides = {"right","left"},
      _shaft_sides = _shaft_sides,
      _shaft_types = _shaft_types,
      _friction = 0.01,
      _I = 50,
      _maxGears = 10,
      
      _rpm_deactivate = true,
      _qgrease_max = 6,
      _qgrease_eff = 5,
      
      sounds = {
        running = {
          sound = "power_generators_shaft_gearbox_running",
          sound_param = {max_hear_distance = 16, gain = 1},
          repeat_timer = 1,
          --update_sound = function(self, pos, meta, old_state, new_state, sound)
          update_sound = function(self, _, meta, _, _, sound)
            local rpm = meta:get_int("L")/meta:get_int("Isum")
            local new_sound = {
              sound = sound.sound,
              sound_param = table.copy(sound.sound_param),
            }
            new_sound.sound_param.gain = math.sqrt(rpm)*0.05
            new_sound.sound_param.pitch = 0.2+rpm*0.016
            return new_sound
          end,
        },
      },
    })

local shaft_gearbox = power_generators.shaft_gearbox

shaft_gearbox:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })

--------------
-- Formspec --
--------------

function shaft_gearbox:get_formspec(meta)
  local inv = meta:get_inventory()
  local cnt1 = inv:get_stack(self.input_stack, 1):get_count()
  local cnt2 = inv:get_stack(self.input_stack, 2):get_count()
  local ratio = (cnt1+1).." : "..(cnt2+1)
  local formspec =  "size[12.75,8.5]" ..
                    "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                    self:get_player_inv() ..
                    self:get_formspec_list("context", self.input_stack, 2, 0.8, 1, 1, 0)..
                    self:get_formspec_list("context", self.input_stack, 9, 0.8, 1, 1, 1)..
                    "label[5.5,1.5;"..ratio.."]" ..
                    "listring[current_player;main]" ..
                    "listring[context;"..self.input_stack.."]" ..
                    "listring[current_player;main]";
  return formspec;
end

---------------
-- Callbacks --
---------------

power_generators.set_rpm_can_dig(shaft_gearbox)

function shaft_gearbox:cb_on_construct(pos)
  local meta = minetest.get_meta(pos)
  meta:set_string(self.meta_infotext, self.node_description)
  meta:set_string("formspec", self:get_formspec(meta, 0, 0))
  local inv = meta:get_inventory()
  inv:set_size(self.input_stack, self.input_stack_size)

  meta:set_int("I", self._I)
  meta:set_int("front_ratio", 1)
  meta:set_int("back_ratio", 1)
  self:call_on_construct(pos, meta)
end

--function shaft_gearbox:cb_allow_metadata_inventory_put(pos, listname, index, stack, player)
function shaft_gearbox:cb_allow_metadata_inventory_put(pos, listname, _, stack, player)
  local player_name
  if player then
    player_name = player:get_player_name()
  end
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  
  local meta = minetest.get_meta(pos)
  if meta:get_int("L")>0 then
    if player_name~="" then
      minetest.chat_send_player(player_name, S("It is rotating! Can't be putten!"))
    end
    return 0
  end
  local item_name = stack:get_name()
  if minetest.get_item_group(item_name, "shaft_gear")>0 then
    local inv = meta:get_inventory()
    local now_front = inv:get_stack(listname, 1)
    local now_back = inv:get_stack(listname, 2)
    local limit = self._maxGears-now_front:get_count()-now_back:get_count()
    local count = stack:get_count()
    if count>limit then
      return math.max(limit, 0)
    end
    return count
  end
  return 0
end
--function shaft_gearbox:cb_allow_metadata_inventory_take(pos, listname, index, stack, player)
function shaft_gearbox:cb_allow_metadata_inventory_take(pos, _, _, stack, player)
  local player_name
  if player then
    player_name = player:get_player_name()
  end
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  
  local meta = minetest.get_meta(pos)
  if meta:get_int("L")>0 then
    if player_name~="" then
      minetest.chat_send_player(player_name, S("It is rotating! Can't be taken!"))
    end
    return 0
  end
  return stack:get_count()
end

--function shaft_gearbox:cb_on_metadata_inventory_put(pos, listname, index, stack, player)
function shaft_gearbox:cb_on_metadata_inventory_put(pos, listname, _, _, _)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
    
  local cnt1 = inv:get_stack(listname, 1):get_count()
  local cnt2 = inv:get_stack(listname, 2):get_count()
  
  meta:set_float("back_ratio", (1+cnt1)/(1+cnt2))
  meta:set_int("I", 50+(cnt1+cnt2)*25)
  meta:set_string("formspec", self:get_formspec(meta, 0, 0))
end

--function shaft_gearbox:cb_on_metadata_inventory_take(pos, listname, index, stack, player)
function shaft_gearbox:cb_on_metadata_inventory_take(pos, listname, _, _, _)
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
    
  local cnt1 = inv:get_stack(listname, 1):get_count()
  local cnt2 = inv:get_stack(listname, 2):get_count()
  
  meta:set_float("back_ratio", (1+cnt1)/(1+cnt2))
  meta:set_int("I", 50+(cnt1+cnt2)*25)
  meta:set_string("formspec", self:get_formspec(meta, 0, 0))
end

function shaft_gearbox:cb_on_production(timer_step)
  power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
end

function shaft_gearbox:cb_waiting(pos, meta)
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
    {-0.4375,-0.0625,-0.125,-0.375,0.0625,-0.0625},
    {0.375,-0.0625,-0.125,0.4375,0.0625,-0.0625},
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
    mesh = "power_generators_shaft_gearbox.obj",
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
        "power_generators_body_steel.png^power_generators_shaft_sides.png",
    },
  }

local node_active = {
    tiles = {
        "power_generators_frame_steel.png",
        "power_generators_shaft_steel.png",
        "power_generators_body_steel.png^power_generators_shaft_sides.png",
    },
  }

shaft_gearbox:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------


