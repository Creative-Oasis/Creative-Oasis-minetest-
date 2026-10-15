-- Universal Fluid API implementation
-- Copyright (c) 2018 Evert "Diamond" Prants <evert@lunasqu.ee>

local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Transfer network
dofile(modpath.."/network.lua")

-- API for ducts and pumps
dofile(modpath.."/api.lua")

-- Simple duct and pump
dofile(modpath.."/register.lua")

-- Crafting recipes
dofile(modpath.."/crafting.lua")
