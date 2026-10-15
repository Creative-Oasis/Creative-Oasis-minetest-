
local modpath = minetest.get_modpath(minetest.get_current_modname())


if minetest.get_modpath("fl_bones") then
  dofile(modpath.."/bones.lua")
end

if minetest.get_modpath("fl_stone") then
  dofile(modpath.."/stone.lua")
end

if minetest.get_modpath("fl_ores") then
  dofile(modpath.."/ores.lua")
end

if minetest.get_modpath("fl_glass") then
  dofile(modpath.."/glass.lua")
end

if minetest.get_modpath("fl_topsoil") then
  dofile(modpath.."/topsoil.lua")
end

if minetest.get_modpath("fl_trees") then
  dofile(modpath.."/trees.lua")
end

if minetest.get_modpath("fl_dyes") then
  dofile(modpath.."/dyes.lua")
end

if minetest.get_modpath("fl_wool") then
  dofile(modpath.."/wool.lua")
end

if minetest.get_modpath("fl_liquids") then
  dofile(modpath.."/liquids.lua")
end

if minetest.get_modpath("fl_stairs") then
  dofile(modpath.."/stairs.lua")
end

if minetest.get_modpath("fl_player") then
  dofile(modpath.."/player.lua")
end

if minetest.get_modpath("fl_core") then
  dofile(modpath.."/groups.lua")
  dofile(modpath.."/screwdriver.lua")
end
