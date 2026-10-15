
local modpath = minetest.get_modpath(minetest.get_current_modname()).."/shaft"

dofile(modpath.."/functions.lua")

dofile(modpath.."/power_supply.lua")

dofile(modpath.."/shaft.lua")
dofile(modpath.."/shaft_horLeft.lua")
dofile(modpath.."/shaft_horTop.lua")
dofile(modpath.."/shaft_verFront.lua")
dofile(modpath.."/shaft_switch.lua")
dofile(modpath.."/shaft_gearbox.lua")

dofile(modpath.."/rpm_meter_watt.lua")

dofile(modpath.."/electric_engine_200.lua")
dofile(modpath.."/electric_engine_400.lua")
dofile(modpath.."/electric_engine_800.lua")
dofile(modpath.."/rpm_meter.lua")

dofile(modpath.."/greases.lua")

dofile(modpath.."/adaptation.lua")

dofile(modpath.."/craftitems.lua")


