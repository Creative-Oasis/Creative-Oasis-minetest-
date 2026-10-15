
local modpath = minetest.get_modpath(minetest.get_current_modname())

if (not minetest.get_modpath("exile_env_sounds")) then
  return
end

if minetest.get_modpath("nodes_nature") then
  dofile(modpath.."/nodes_nature.lua")
end

if minetest.get_modpath("player_api") then
  dofile(modpath.."/player_api.lua")
end

