--[[
	This file is part of the Alien Material, a mod which contains much about aliens!

	Copyright (C) 2020-2024  debiankaios

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.

	==============
	Biomes
]]--

local S = alien_material.S


minetest.register_biome({
	name = "aliendesert",
	node_top = "alien_material:alien_sand",
	depth_top = 1,
	node_filler = "alien_material:alien_sand",
	depth_filler = 3,
	y_max = 31000,
	y_min = -3,
	heat_point = 20,
	humidity_point = 0,
})

minetest.register_decoration({
	name = "alien_material:dry_shrub",
	deco_type = "simple",
	place_on = {"alien_material:alien_sand"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.02,
		spread = {x = 200, y = 200, z = 200},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {"aliendesert"},
	y_max = 31000,
	y_min = -3,
	decoration = "default:dry_shrub",
	param2 = 4,
})
