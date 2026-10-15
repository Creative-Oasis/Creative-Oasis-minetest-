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
	Ores
]]--

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "alien_material:alien_mese_ore",
    wherein        = "default:stone",
    clust_scarcity = 28*28*28,
    clust_num_ores = 4,
    clust_size     = 2,
    y_min     = -31000,
    y_max     = -2048,
})




minetest.register_ore({
    ore_type       = "scatter",
    ore            = "alien_material:alien_diamond_ore",
    wherein        = "default:stone",
    clust_scarcity = 22*22*22,
    clust_num_ores = 4,
    clust_size     = 2,
    y_min     = -31000,
    y_max     = -2048,
})



minetest.register_ore({
    ore_type       = "scatter",
    ore            = "alien_material:alien_mese_block",
    wherein        = "default:stone",
    clust_scarcity = 40*40*40,
    clust_num_ores = 4,
    clust_size     = 2,
    y_min     = -31000,
    y_max     = -4096,
})
