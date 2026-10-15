
adaptation_lib = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

adaptation_lib.have_developer_commands = minetest.settings:get_bool("adaptation_lib_developer_commands", false) 

dofile(modpath.."/base.lua")
dofile(modpath.."/api.lua")

dofile(modpath.."/functions.lua")

if adaptation_lib.have_developer_commands then
  dofile(modpath.."/export.lua")
  dofile(modpath.."/check.lua")
end
