
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("ks_terrain") then
  dofile(modpath.."/terrain.lua")
end

if minetest.get_modpath("ks_flora") then
  dofile(modpath.."/flora.lua")
end

