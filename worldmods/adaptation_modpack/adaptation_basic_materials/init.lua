
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("basic_materials") then
 dofile(modpath.."/materials.lua")
end

