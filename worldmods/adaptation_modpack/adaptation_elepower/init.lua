
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("elepower_dynamics") then
  dofile(modpath.."/dynamics.lua")
end

