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

]]--

alien_material = {}

alien_material.version = "0.12"
alien_material.protocol_version = 10 -- Version as number
alien_material.status = "Main" -- Pre aren't stable Version and Main are the main versions

alien_material.S = minetest.get_translator("alien_material")

-- dofile
dofile(minetest.get_modpath("alien_material") .. "/ores.lua")
dofile(minetest.get_modpath("alien_material") .. "/tools.lua")
dofile(minetest.get_modpath("alien_material") .. "/alien_apple.lua") -- Alien apples and Alien hearts
dofile(minetest.get_modpath("alien_material") .. "/biomes.lua")
-- test
dofile(minetest.get_modpath("alien_material") .. "/alienbench.lua")
dofile(minetest.get_modpath("alien_material") .. "/items.lua")
dofile(minetest.get_modpath("alien_material") .. "/crafting.lua")
if minetest.get_modpath("3d_armor") then
	dofile(minetest.get_modpath("alien_material") .. "/armor.lua")
end
if minetest.get_modpath("mobs") then
	dofile(minetest.get_modpath("alien_material") .. "/alien.lua")
end

-- local S = alien_material.S

-- minetest.register_privilege("alien", "Needed for special Things in Alien Material!")
