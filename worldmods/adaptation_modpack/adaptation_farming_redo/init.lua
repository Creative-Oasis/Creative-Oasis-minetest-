
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("farming") and minetest.global_exists("farming") and (farming.mod=="redo") then
  dofile(modpath.."/shared.lua")
  dofile(modpath.."/farming.lua")
end

if minetest.get_modpath("hades_extrafarming") and minetest.global_exists("farming") and (farming.mod=="redo") then
  dofile(modpath.."/shared.lua")
  dofile(modpath.."/extrafarming.lua")
end

