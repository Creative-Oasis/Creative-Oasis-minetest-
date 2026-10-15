
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("mobs_animal") or minetest.get_modpath("hades_animals") then
  dofile(modpath.."/animal.lua")
end

