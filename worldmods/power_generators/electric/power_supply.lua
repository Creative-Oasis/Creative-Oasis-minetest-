
-- register power supply to power generators

local S = power_generators.translator

local Cable = power_generators.electric_cable

local tubelib2_side = {
    right = "R",
    left = "L",
    front = "F",
    back = "B",
    top = "U",
    bottom = "D",
  }

local power_supply = {
    units = S("PG EU"),
    is_powered = function (self, power_data, pos, meta)
        local eu_input = meta:get_int("generator_input");
        local demand = power_data.demand or power_data.get_demand(self, pos, meta)
        if (eu_input>=demand) then
          -- prevent run, when connection lost
          meta:set_int("generator_input", 0)
          return power_data.run_speed;
        end
        return 0;
      end,
    power_need = function (self, power_data, pos, meta)
        local demand = power_data.demand or power_data.get_demand(self, pos, meta)
        meta:set_int("generator_demand", demand)
      end,
    --power_idle = function (self, power_data, pos, meta)
    power_idle = function (self, _, _, meta)
        meta:set_int("generator_demand", 0)
      end,
    --update_node_def = function(self, power_data, node_def)
    update_node_def = function(self, _, node_def)
        node_def.groups.generator_powered = 1;
        node_def._generator_connect_sides = self.power_connect_sides;
        node_def._generator_powered_valid_sides = {}
        for _,side in pairs(self.power_connect_sides) do
          node_def._generator_powered_valid_sides[tubelib2_side[side]] = true
        end
      end,
    --after_register_node = function(self, power_data)
    after_register_node = function(self, _)
        local names = {self.node_name_active, self.node_name_inactive}
        if self.node_name_waiting then
          table.insert(names, self.node_name_waiting)
        end
        local sides = {}
        for _,side in pairs(self.power_connect_sides) do
          table.insert(sides, tubelib2_side[side])
        end
        for _,name in pairs(names) do
          Cable:add_secondary_node_names({name})
          --Cable:add_special_node_names({name})
          Cable:set_valid_sides(name, sides)
        end
      end,
  }
appliances.add_power_supply("power_generators_electric_power", power_supply)

--[[
function power_generators.need_power(pos, gen_pos)
  local node = minetest.get_node(pos);
  if (minetest.get_item_group(node.name, "generator_powered")>0) then
    
  end
  return 0;
end
--]]

-- abm function
--[[
minetest.register_abm({
    label = "Check generator powered appliances",
    nodenames = {"group:generator_powered"},
    interval = 1,
    chance = 1,
    action = function(pos, node)
      local node_def = minetest.registered_nodes[node.name]
      for _,side in pairs(node_def._generator_connect_sides) do
        local side_pos = appliances.get_side_pos(pos, node, side);
        local side_node = minetest.get_node(side_pos);
        if minetest.get_item_group(side_node.name, "power_generator")>0 then
          return
        end
      end
      local meta = minetest.get_meta(pos)
      meta:set_int("generator_input", 0)
    end,
 })
--]]
