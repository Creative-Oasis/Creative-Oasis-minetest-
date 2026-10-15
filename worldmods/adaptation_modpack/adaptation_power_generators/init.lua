
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("power_generators") then
 dofile(modpath.."/power_generators.lua")
end

