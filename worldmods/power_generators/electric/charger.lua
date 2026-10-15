-------------
-- Charger --
-------------
-- Ver 1.0 --
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;

power_generators.charger = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:charger",
      node_name_active = "power_generators:charger_active",
      
      node_description = S("Electric Charger"),
      node_help = "",
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      output_stack_size = 1,
      
      power_connect_sides = {"back","front","right","left","bottom","top"},
      
      have_control = true,
    })

local charger = power_generators.charger

charger:power_data_register(
  {
    ["no_power"] = {
        disable = {}
      },
    ["LV_power"] = {
        demand = 200,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["power_generators_electric_power"] = {
        demand = 200,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["elepower_power"] = {
        demand = 16,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["techage_electric_power"] = {
        demand = 80,
        run_speed = 1,
        disable = {"no_power"}
      },
    ["factory_power"] = {
        demand = 10,
        run_speed = 1,
        disable = {"no_power"}
      },
  })
charger:control_data_register(
  {
    ["punch_control"] = {
        power_off_on_deactivate = true,
      },
  })

charger.node_help = S("Connect to power (@1).", charger:get_power_help()).."\n"..charger.node_help

--------------
-- Formspec --
--------------

-- form spec
function charger:get_formspec()
  local formspec =  "size[12.75,8.5]" ..
                    "background[-1.25,-1.25;15,10;appliances_appliance_formspec.png]" ..
                    self:get_player_inv() ..
                    self:get_formspec_list("context", self.output_stack, 4.75,1,1,1)..
                    "listring[current_player;main]" ..
                    "listring[context;"..self.output_stack.."]" ..
                    "listring[current_player;main]";
  return formspec;
end

---------------
-- Callbacks --
---------------

function charger:recipe_inventory_can_put(pos, listname, index, stack, player_name)
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  local meta = minetest.get_meta(pos)
  local inv = meta:get_inventory()
  local is_in = inv:get_stack(listname, index)
  if is_in:get_count()==0 then
    local def = stack:get_definition()
    if def and def._PG_batt_get_charge and def._PG_batt_set_charge then
      return 1;
    end
  end
  return 0
end
function charger:recipe_inventory_can_take(pos, listname, index, stack, player_name)
  if player_name then
    if minetest.is_protected(pos, player_name) then
      return 0
    end
  end
  return 1
end

function charger:cb_on_production(timer_step)
  -- charge
  local stack = timer_step.inv:get_stack(self.output_stack, 1)
  local def = stack:get_definition()
  if def._PG_batt_get_charge then
    local charge, max_charge = def._PG_batt_get_charge(stack)
    charge = math.min(charge+200*timer_step.speed, max_charge)
    def._PG_batt_set_charge(stack, charge)
    timer_step.inv:set_stack(self.output_stack, 1, stack)
  end
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

local node_def = {
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 2, shaft = 1, greasable = 1},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = node_sounds,
    
    _inspect_msg_func = power_generators.grease_inspect_msg,
 }

local node_inactive = {
    tiles = {
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_front.png",
    },
  }

local node_active = {
    tiles = {
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        "power_generators_electric_charger_side.png",
        {
          image = "power_generators_electric_charger_front_active.png",
          backface_culling = false,
          animation = {
            type = "vertical_frames",
            aspect_w = 32,
            aspect_h = 32,
            length = 1.5
          }
        },
        "power_generators_electric_charger_side.png",
    },
  }

charger:register_nodes(node_def, node_inactive, node_active)

-------------------------
-- Recipe Registration --
-------------------------

