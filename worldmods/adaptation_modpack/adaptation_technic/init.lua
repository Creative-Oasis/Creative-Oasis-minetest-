
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("technic") then
 dofile(modpath.."/shared.lua")
 dofile(modpath.."/technic.lua")
end

if minetest.get_modpath("hades_technic") then
 dofile(modpath.."/shared.lua")
 dofile(modpath.."/hades_technic.lua")
end

