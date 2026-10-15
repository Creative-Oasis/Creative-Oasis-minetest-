
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("clothing_machines") then
  dofile(modpath.."/clothing_machines.lua")
end

