
-- register battery supply to power generators

local S = power_generators.translator

local battery_supply = {
    units = S("PG EU"),
    update_tool_def = function (self, battery_supply, tool_def)
      tool_def._PG_batt_get_charge = function(itemstack)
          local meta = itemstack:get_meta()
          return self:get_energy(itemstack, meta), self.max_stored_energy
        end
      tool_def._PG_batt_set_charge = function(itemstack, charge)
          local meta = itemstack:get_meta()
          self:set_energy(itemstack, meta, charge)
          self:update_wear(itemstack, meta)
        end
    end,
  }
appliances.add_battery_supply("power_generators_battery", battery_supply)


