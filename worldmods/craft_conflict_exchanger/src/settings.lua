craft_conflict_exchanger.settings = {}
local set = craft_conflict_exchanger.settings

local function C(str) return "craft_conflict_exchanger_"..str end

local function get_bool (key, default)
  return core.settings:get_bool(C(key), default)
end

--------------------------------
-- Settings
--------------------------------

set.allowExchangerCrafting = get_bool("allow_exchanger_crafting", true)

set.allowExchangerCommand = get_bool("allow_exchanger_command", true)
