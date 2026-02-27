-- Minetest 5.3 mod: too many stones
-- See README.txt for licensing and other information.

-- Definitions made by this mod that other mods can use too
too_many_stones = {}

local S = minetest.get_translator("too_many_stones")

-- Load files
local default_path = minetest.get_modpath("too_many_stones")


dofile(minetest.get_modpath("too_many_stones") .. "/sounds.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/nodes.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/crafting.lua")
-- Game detection and mapgen loading
local modpath = minetest.get_modpath("too_many_stones")

if minetest.get_modpath("default") then
	-- Minetest Game
	dofile(modpath .. "/mapgen_default.lua")
elseif minetest.get_modpath("base_earth") then
	-- Minebase (deprecated)
	dofile(modpath .. "/mapgen_minebase.lua")
elseif minetest.get_modpath("mcl_levelgen") then
	-- Mineclonia (has mcl_levelgen, check before mcl_biomes)
	dofile(modpath .. "/mapgen_mineclonia.lua")
elseif minetest.get_modpath("mcl_biomes") then
	-- VoxeLibre
	dofile(modpath .. "/mapgen_voxelibre.lua")
else
	-- Generic fallback for other games
	dofile(modpath .. "/mapgen_fallback.lua")
end
dofile(minetest.get_modpath("too_many_stones") .. "/wall.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/stairs.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/geodes.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/geodes_lib.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/nodes_glowing.lua")
dofile(minetest.get_modpath("too_many_stones") .. "/nodes_crystal.lua")
