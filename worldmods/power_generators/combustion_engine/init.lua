
local modpath = minetest.get_modpath(minetest.get_current_modname()).."/combustion_engine"

dofile(modpath.."/functions.lua")

dofile(modpath.."/combustion_engine_6.lua")
--dofile(modpath.."/combustion_engine_8.lua")

dofile(modpath.."/fuel_tank.lua")

dofile(modpath.."/gearbox.lua")
dofile(modpath.."/starter_manual.lua")
--dofile(modpath.."/starter_electric.lua")

dofile(modpath.."/adaptation.lua")

dofile(modpath.."/craftitems.lua")

