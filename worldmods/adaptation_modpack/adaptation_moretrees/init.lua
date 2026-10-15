
local modpath = minetest.get_modpath(minetest.get_current_modname())

if minetest.get_modpath("moretrees") then
  dofile(modpath.."/shared.lua")
  dofile(modpath.."/moretrees.lua")
end

if minetest.get_modpath("hades_moretrees") then
  dofile(modpath.."/shared.lua")
  dofile(modpath.."/hades_moretrees.lua")
end

