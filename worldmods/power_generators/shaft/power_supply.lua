
local S = power_generators.translator

local power_supply = {
    units = S("PG shaft"),
    is_powered = function (self, power_data, pos, meta)
        local I = meta:get_int("I");
        local L = meta:get_int("L")
        local rpm = L/I
        
        local demand = power_data.demand or power_data.get_demand(self, pos, meta)
        if (rpm>=demand) then
          return power_data.run_speed;
        end
        return 0;
      end,
    --power_need = function (self, power_data, pos, meta)
    power_need = function (self)
      end,
    --power_idle = function (self, power_data, pos, meta)
    power_idle = function (self)
      end,
    --on_production = function (self, power_data, timer_step)
    on_production = function (self, _, timer_step)
        power_generators.shaft_step(self, timer_step.pos, timer_step.meta, timer_step.use_usage)
      end,
    --waiting = function (self, power_data, pos, meta)
    waiting = function (self, _, pos, meta)
        power_generators.shaft_step(self, pos, meta, nil)
      end,
    --no_power = function (self, power_data, pos, meta)
    no_power = function (self, _, pos, meta)
        power_generators.shaft_step(self, pos, meta, nil)
      end,
    update_node_def = function(self, power_data, node_def)
        node_def.groups.shaft = 1;
        node_def._shaft_sides = self.power_connect_sides;
        self._shaft_sides = self.power_connect_sides
        node_def._shaft_types = self._shaft_types
        node_def._friction = power_data.friction
        self._friction = power_data.friction
        node_def._I = power_data.I
        self._I = power_data.I
        
        self._rpm_deactivate = power_data.rpm_deactivate
        self._qgrease_max = power_data.qgrease_max
        self._qgrease_eff = power_data.qgrease_eff
        if power_data.qgrease_eff>0 then
          node_def.groups.greasable = 1
        end
      end,
    --on_construct = function(self, power_data, pos, meta)
    on_construct = function(self, power_data, _, meta)
        meta:set_int("I", power_data.I)
        meta:set_int("Isum", power_data.I)
        for _,side in pairs(self._shaft_sides) do
          meta:set_int(side.."_ratio", 1)
        end
        meta:set_float("friction", power_data.friction)
      end,
  }
appliances.add_power_supply("power_generators_shaft_power", power_supply)

