
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("biofuel") then
 dofile(modpath.."/shared.lua")
 dofile(modpath.."/biofuel.lua")
end

if minetest.get_modpath("hades_biofuel") then
 dofile(modpath.."/shared.lua")
 dofile(modpath.."/hades_biofuel.lua")
end

