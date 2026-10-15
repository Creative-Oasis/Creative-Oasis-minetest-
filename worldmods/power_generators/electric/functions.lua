
local Cable = power_generators.electric_cable

local tubelib2_side = {
    right = "R",
    left = "L",
    front = "F",
    back = "B",
    top = "U",
    bottom = "D",
  }

local function get_connected_node(pos, side)
  local _,node = Cable:get_node(pos)
  local dir = tubelib2.side_to_dir(side, node.param2)
  local epos, edir = Cable:get_connected_node_pos(pos, dir)
  if not (epos and edir) then
    return nil, nil
  end
  _,node = Cable:get_node(epos)
  local out_side = tubelib2.dir_to_side(tubelib2.Turn180Deg[edir], node.param2)
  local node_def = minetest.registered_nodes[node.name];
  if node_def and node_def._generator_powered_valid_sides and node_def._generator_powered_valid_sides[out_side] then
    return epos, out_side
  end
  return nil, nil
end

function power_generators.update_generator_supply(sides, pos, use_usage)
  local side_data = {};
  local total_demand = 0;
  local generator_output = 0;
  if use_usage then
    generator_output = use_usage.generator_output or 150;
  end
  local need_update = minetest.get_meta(pos):get_int("update")
  for _,side in pairs(sides) do
    local side_pos, side_dir = get_connected_node(pos, tubelib2_side[side])
    if side_pos then
      local side_node = minetest.get_node(side_pos);
      local side_def = minetest.registered_nodes[side_node.name];
      if side_def and side_def._generator_connect_sides then
        local meta = minetest.get_meta(side_pos);
        local timer = minetest.get_node_timer(side_pos);
        local demand = meta:get_int("generator_demand") or 0
        if (demand>0) then
          total_demand = total_demand + demand;
          table.insert(side_data, {
            meta = meta,
            demand = demand,
            set_func = side_def.set_PG_power_input,
            dir = side_dir,
            timer = timer,});
        else
          meta:set_int("generator_input", 0)
          if (generator_output>0) or (need_update>0) then
            if not timer:is_started() then
              meta:set_int("update", 1)
              timer:start(1)
            end
          end
        end
      end
    end
  end
  
  if (total_demand>0) then
    local part = generator_output/total_demand;
    
    for _,side in pairs(side_data) do
      local demand = math.floor(side.demand*part)
      if side.set_func then
        side.set_func(side.meta, side.dir, demand)
      else
        side.meta:set_int("generator_input", demand)
      end
      if demand>0 then
        if not side.timer:is_started() then
          side.timer:start(1)
        end
      end
    end
  end
  
  return total_demand
end

