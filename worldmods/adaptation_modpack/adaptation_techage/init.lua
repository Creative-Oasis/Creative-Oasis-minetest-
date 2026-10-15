
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("techage") then
  dofile(modpath.."/techage.lua")
end

