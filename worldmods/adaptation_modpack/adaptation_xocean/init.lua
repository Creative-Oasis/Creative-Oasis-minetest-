
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("xocean") then
 dofile(modpath.."/shared.lua")
 dofile(modpath.."/xocean.lua")
end

if minetest.get_modpath("hades_xocean") then
 dofile(modpath.."/shared.lua")
 dofile(modpath.."/hades_xocean.lua")
end

