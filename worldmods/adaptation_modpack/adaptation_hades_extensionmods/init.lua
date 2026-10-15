
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("hades_extravessels") then
  dofile(modpath.."/vessels.lua")
end

if minetest.get_modpath("hades_bucket") then
  dofile(modpath.."/bucket.lua")
end

