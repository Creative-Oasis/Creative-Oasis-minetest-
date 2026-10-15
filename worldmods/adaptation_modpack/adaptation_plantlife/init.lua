
local modpath = core.get_modpath(core.get_current_modname())

if minetest.get_modpath("vines") then
  dofile(modpath.."/vines.lua")
end

