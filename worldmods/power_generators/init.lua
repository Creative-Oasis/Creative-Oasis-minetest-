
minetest.log("action", "[MOD] Power Generators loading...")

power_generators = {
  translator = minetest.get_translator("power_generators")
}

local modpath = minetest.get_modpath(minetest.get_current_modname())

appliances.register_craft_type("power_generators_fuel", {
    description = "Combustion engine fuel",
    icon = "power_generators_fuel_recipe_icon.png",
    width = 1,
    height = 1,
  })

dofile(modpath.."/setting.lua")

dofile(modpath.."/adaptation.lua")

dofile(modpath.."/electric/init.lua")
dofile(modpath.."/shaft/init.lua")
dofile(modpath.."/generators/init.lua")
dofile(modpath.."/combustion_engine/init.lua")
if power_generators.settings.enable_petrol_tools then
  dofile(modpath.."/petrol_tools/init.lua")
end

dofile(modpath.."/nodes.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/crafting.lua")

minetest.log("action", "[MOD] Power Generators loaded.")

