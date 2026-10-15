
-- register power supply fot tools powered by combustion engine

local S = power_generators.translator

local battery_supply = {
    update_tool_def = function (self, _battery_data, tool_def)
      end,
  }
appliances.add_battery_supply("power_generators_combustion_power_battery", battery_supply)
