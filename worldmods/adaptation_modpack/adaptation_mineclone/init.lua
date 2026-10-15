
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("mcl_core") then
  dofile(modpath.."/core.lua")
end

if minetest.get_modpath("mcl_farming") then
  dofile(modpath.."/farming.lua")
end

if minetest.get_modpath("mcl_dye") then
  dofile(modpath.."/dye.lua")
end

if minetest.get_modpath("mcl_wool") then
  dofile(modpath.."/wool.lua")
end

if minetest.get_modpath("mcl_buckets") then
  dofile(modpath.."/buckets.lua")
end

if minetest.get_modpath("mcl_torches") then
  dofile(modpath.."/torches.lua")
end

if minetest.get_modpath("mcl_copper") then
  dofile(modpath.."/copper.lua")
end

if minetest.get_modpath("mcl_chests") then
  dofile(modpath.."/chests.lua")
end

if minetest.get_modpath("mcl_mobitems") then
  dofile(modpath.."/mobitems.lua")
end

if minetest.get_modpath("mcl_stairs") then
  dofile(modpath.."/stairs.lua")
end

if minetest.get_modpath("mcl_core") and minetest.get_modpath("mesecons") then
  dofile(modpath.."/mesecons.lua")
end

if minetest.get_modpath("mcl_player") then
  dofile(modpath.."/player.lua")
end


if minetest.get_modpath("mcl_core") then
  dofile(modpath.."/groups.lua")
end

