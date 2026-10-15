
-- moment and revolution
-- I -> moment of inertia
-- T -> torque
-- rpm -> revolution

--function power_generators.ce_gearbox_shifting(self, pos, node, meta)
function power_generators.ce_gearbox_shifting(self, _pos, _node, meta)
  local shifting = meta:get_string("shifting")
  if shifting=="shaft" then
    meta:set_float(self._shaft_side.."_ratio", 1)
    meta:set_float(self._starter_side.."_ratio", 0)
    meta:set_float(self._shaft_side.."_engine", 0)
    meta:set_float(self._starter_side.."_engine", 0)
    --local shaft_pos = appliances.get_side_pos(pos, node, self._shaft_side)
    
  elseif shifting=="starter" then
    meta:set_float(self._shaft_side.."_ratio", 0)
    meta:set_float(self._starter_side.."_ratio", 10)
    meta:set_float(self._shaft_side.."_engine", 0)
    meta:set_float(self._starter_side.."_engine", 0)
    meta:set_float(self._engine_side.."_engine", 0)
    --local starter_pos = appliances.get_side_pos(pos, node, self._starter_side)
  else -- neutral
    meta:set_float(self._shaft_side.."_ratio", 0)
    meta:set_float(self._starter_side.."_ratio", 0)
    meta:set_float(self._shaft_side.."_engine", 0)
    meta:set_float(self._starter_side.."_engine", 0)
    meta:set_float(self._engine_side.."_engine", 0)
  end
  
  -- engine check?
  meta:set_int("minT", 0)
  meta:set_int("Isum", meta:get_int("I"))
  meta:set_string("update", 1)
end

--function power_generators.ce_get_torque(self, pos, meta, rpm, I, speed)
function power_generators.ce_get_torque(self, pos, meta, rpm)
  if rpm>0 then
    local tank_pos = appliances.get_side_pos(pos, nil, "top")
    local tank = minetest.get_node(tank_pos)
    local tank_def = minetest.registered_nodes[tank.name]
    if tank_def and tank_def._take_fuel then
      local tank_meta = minetest.get_meta(tank_pos)
      local throttle = meta:get_float("throttle")
      local amount_want = self._fuel_per_rpm*rpm * throttle
      local amount = tank_def._take_fuel(pos, tank, tank_meta, amount_want)
      local T = (self._coef2*rpm*rpm + self._coef1*rpm + self._coef0)*throttle
      local post_effect = amount/amount_want
      if post_effect>1 then
        T = T * math.sqrt(post_effect)
      else
        T = T * post_effect*post_effect
      end
      --print("ce torque: "..T.." om rpm: "..rpm)
      return math.max(T, 0)
    end
  end
  return 0
end

--function power_generators.cesm_get_torque(self, pos, meta, rpm, I, speed)
function power_generators.cesm_get_torque(self, _pos, _meta, rpm)
  local T = self._maxT-rpm*self._coef
  return math.max(T, 0)
end

