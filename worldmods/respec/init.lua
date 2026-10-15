
respec = {}

respec.MODNAME = minetest.get_current_modname()
respec.MODPATH = minetest.get_modpath(respec.MODNAME)

dofile(respec.MODPATH.."/src/src.lua")
