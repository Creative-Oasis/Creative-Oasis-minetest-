
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("rp_default") then
  dofile(modpath.."/default.lua")
end

if minetest.get_modpath("rp_player") then
  dofile(modpath.."/player.lua")
end

