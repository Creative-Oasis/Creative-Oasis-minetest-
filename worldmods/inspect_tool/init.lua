
inspect_tool = {
  translator = minetest.get_translator("inspect_tool")
}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/functions.lua")

dofile(modpath.."/inspect_tools.lua")
dofile(modpath.."/crafting.lua")

