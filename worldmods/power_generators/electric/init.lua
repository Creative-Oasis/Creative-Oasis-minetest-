
local modpath = minetest.get_modpath(minetest.get_current_modname()).."/electric"

dofile(modpath.."/electric_network.lua")
dofile(modpath.."/power_supply.lua")
dofile(modpath.."/electric_junction.lua")

dofile(modpath.."/functions.lua")

dofile(modpath.."/battery_supply.lua")

dofile(modpath.."/power_meter.lua")
dofile(modpath.."/charger.lua")

--dofile(modpath.."/craftitems.lua")
--dofile(modpath.."/crafting.lua")

