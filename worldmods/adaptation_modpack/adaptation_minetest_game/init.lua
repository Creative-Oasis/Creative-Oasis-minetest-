
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("default") then
  dofile(modpath.."/default.lua")
end

if minetest.get_modpath("dye") then
  dofile(modpath.."/dye.lua")
end

if minetest.get_modpath("wool") then
  dofile(modpath.."/wool.lua")
end

if minetest.get_modpath("vessels") then
  dofile(modpath.."/vessels.lua")
end

if minetest.get_modpath("bucket") then
  dofile(modpath.."/bucket.lua")
end

if minetest.get_modpath("farming") then
  dofile(modpath.."/farming.lua")
end

if minetest.get_modpath("player_api") then
  dofile(modpath.."/player_api.lua")
end

if minetest.get_modpath("stairs") then
  dofile(modpath.."/stairs.lua")
end

if minetest.get_modpath("default") then
  dofile(modpath.."/groups.lua")
end

