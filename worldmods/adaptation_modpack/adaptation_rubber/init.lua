
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("mcl_rubber") then
  dofile(modpath.."/rubber.lua")
end

