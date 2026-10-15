--------------------
-- Test Generator --
--------------------
----- Ver 1.0 ---------
-----------------------
-- Initial Functions --
-----------------------
local S = power_generators.translator;
local Cable = power_generators.electric_cable

power_generators.test_generator = appliances.appliance:new(
    {
      node_name_inactive = "power_generators:test_generator",
      node_name_active = "power_generators:test_generator_active",
      
      node_description = S("Test Generator"),
      node_help = S("Use this for generate 10k unit of energy.").."\n"..S("Startup and Shutdown by punch."),
      
      input_stack_size = 0,
      have_input = false,
      use_stack_size = 0,
      have_usage = false,
      
      power_connect_sides = {"front","back","right","left"},
      
      have_control = true,
    })

local test_generator = power_generators.test_generator

test_generator:power_data_register(
  {
    ["time_power"] = {
        run_speed = 1,
        disable = {}
      },
  })
test_generator:control_data_register(
  {
    ["punch_control"] = {
        power_off_on_deactivate = true,
      },
  })

--------------
-- Formspec --
--------------

function test_generator:get_formspec()
  return ""
end

---------------
-- Callbacks --
---------------


function test_generator:cb_on_production(timer_step)
  local use_usage = {
    generator_output = 10000,
  }
  power_generators.update_generator_supply(self.power_connect_sides, timer_step.pos, use_usage)
end

--function test_generator:cb_waiting(pos, meta)
function test_generator:cb_waiting(pos)
  power_generators.update_generator_supply(self.power_connect_sides, pos, nil)
end

--function test_generator:cb_deactivate(pos, meta)
function test_generator:cb_deactivate(pos)
  power_generators.update_generator_supply(self.power_connect_sides, pos, nil)
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
    groups = {cracky = 2, power_generator = 1},
    legacy_facedir_simple = true,
    is_ground_content = false,
    sounds = node_sounds,
    drawtype = "normal",
    tiles = {
      "power_generators_test_generator_side.png",
      "power_generators_test_generator_side.png",
      "power_generators_test_generator_side.png",
      "power_generators_test_generator_side.png",
      "power_generators_test_generator_side.png",
      "power_generators_test_generator_side.png",
    },
 }

test_generator:register_nodes(node_def, nil, nil)

Cable:add_secondary_node_names({test_generator.node_name_active, test_generator.node_name_inactive})
--Cable:add_special_node_names({name})
Cable:set_valid_sides(test_generator.node_name_active, {"R", "L", "F", "B", "U", "D"})
Cable:set_valid_sides(test_generator.node_name_inactive, {"R", "L", "F", "B", "U", "D"})

-------------------------
-- Recipe Registration --
-------------------------

