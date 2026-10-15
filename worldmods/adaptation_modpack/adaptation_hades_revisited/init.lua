
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("hades_core") then
  dofile(modpath.."/core.lua")
end

if minetest.get_modpath("hades_dye") then
  dofile(modpath.."/dye.lua")
end

if minetest.get_modpath("hades_trees") then
  dofile(modpath.."/trees.lua")
end

if minetest.get_modpath("hades_cloth") then
  dofile(modpath.."/cloth.lua")
end

if minetest.get_modpath("hades_glowcrystals") then
  dofile(modpath.."/glowcrystals.lua")
end

if minetest.get_modpath("hades_materials") then
  dofile(modpath.."/materials.lua")
end

if minetest.get_modpath("hades_farming") then
  dofile(modpath.."/farming.lua")
end

if minetest.get_modpath("hades_grass") then
  dofile(modpath.."/grass.lua")
end

if minetest.get_modpath("hades_stairs") then
  dofile(modpath.."/stairs.lua")
end

if minetest.get_modpath("hades_chests") then
  dofile(modpath.."/chests.lua")
end

if minetest.get_modpath("hades_vessels") then
  dofile(modpath.."/vessels.lua")
end

if minetest.get_modpath("hades_vines") then
  dofile(modpath.."/vines.lua")
end

if minetest.get_modpath("hades_player") then
  dofile(modpath.."/player.lua")
end

if minetest.get_modpath("hades_core") then
  dofile(modpath.."/groups.lua")
end

