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
	Crafting
]]--

minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_mese_fragment 9",
    recipe = {
        {"alien_material:alien_mese"},
    }
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_mese",
    recipe = {
        {"alien_material:alien_mese_fragment",  "alien_material:alien_mese_fragment",  "alien_material:alien_mese_fragment",},
				{"alien_material:alien_mese_fragment",  "alien_material:alien_mese_fragment",  "alien_material:alien_mese_fragment",},
				{"alien_material:alien_mese_fragment",  "alien_material:alien_mese_fragment",  "alien_material:alien_mese_fragment",},
    }
})






minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_diamond_block",
    recipe = {
        {"alien_material:alien_diamond",  "alien_material:alien_diamond",  "alien_material:alien_diamond",},
				{"alien_material:alien_diamond",  "alien_material:alien_diamond",  "alien_material:alien_diamond",},
				{"alien_material:alien_diamond",  "alien_material:alien_diamond",  "alien_material:alien_diamond",},
    }
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_mese_block",
    recipe = {
        {"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
				{"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
				{"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
    }
})




minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_mese 9",
    recipe = {
        {"alien_material:alien_mese_block"},
    }
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_mese_block",
    recipe = {
        {"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
				{"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
				{"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
    }
})





-- Tools

minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_pickaxe",
	recipe = {
	{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
		{"",  "alien_material:alien_mese_fragment",  "",},
		{"",  "alien_material:alien_mese_fragment",  "",},
	}
})

minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_axe",
	recipe = {
		{"alien_material:alien_ingot",  "alien_material:alien_ingot",},
		{"alien_material:alien_mese_fragment",  "alien_material:alien_ingot",},
		{"alien_material:alien_mese_fragment",  "",},
	}
})

minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_sword",
	recipe = {
		{"alien_material:alien_ingot",},
		{"alien_material:alien_ingot",},
		{"alien_material:alien_mese_fragment",},
	}
})

minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_spade",
	recipe = {
		{"alien_material:alien_ingot",},
		{"alien_material:alien_mese_fragment",},
		{"alien_material:alien_mese_fragment",},
	}
})

minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_multitool",
	recipe = {
		{"alien_material:alien_axe",  "alien_material:alien_pickaxe",  "alien_material:alien_spade"},
		{"alien_material:alien_mese",  "alien_material:alien_sword",  "alien_material:alien_mese"}
	}
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_ingot",
    recipe = {
        {"alien_material:alien_mese",  "alien_material:alien_diamond",},
    }
})






minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_block",
	recipe = {
		{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
		{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
		{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
	}
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_ingot",
    recipe = {
        {"alien_material:alien_block",},
        }
})


-- armor


minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_chestplate",
    recipe = {
        {"alien_material:alien_ingot",  "",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
    }
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_leggings",
    recipe = {
        {"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "",  "alien_material:alien_ingot",},
    }
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_shield",
    recipe = {
        {"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
				{"",  "alien_material:alien_ingot",  "",},
    }
})




minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_helmet",
    recipe = {
        {"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "",  "alien_material:alien_ingot",},
    }
})





minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_boots",
    recipe = {
        {"alien_material:alien_ingot",  "",  "alien_material:alien_ingot",},
				{"alien_material:alien_ingot",  "",  "alien_material:alien_ingot",},
    }
})




minetest.register_craft({
    type = "shaped",
    output = "alien_material:alien_post_light 3",
    recipe = {
        {"",  "default:glass",  "",},
				{"alien_material:alien_mese",  "alien_material:alien_mese",  "alien_material:alien_mese",},
				{"",  "group:wood",  "",},
    }
})





-- Fuel
minetest.register_craft({
  type = "fuel",
  recipe = "alien_material:alien_ingot",
  burntime = 1024,
})


-- Alienbench
minetest.register_craft({
	type = "shaped",
	output = "alien_material:alienbench",
	recipe = {
		{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
		{"alien_material:alien_ingot",  "alien_material:alien_diamond_block",  "alien_material:alien_ingot",},
		{"alien_material:alien_ingot",  "alien_material:alien_ingot",  "alien_material:alien_ingot",},
	}
})

-- Alienbricks
minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_brick_1 4",
	recipe = {
		{"alien_material:alien_sand", "alien_material:alien_sand"},
		{"alien_material:alien_sand", "alien_material:alien_sand"}
	}
})

minetest.register_craft({
	type = "shaped",
	output = "alien_material:alien_brick_2 9",
	recipe = {
		{"alien_material:alien_sand", "alien_material:alien_sand", "alien_material:alien_sand"},
		{"alien_material:alien_sand", "alien_material:alien_sand", "alien_material:alien_sand"},
		{"alien_material:alien_sand", "alien_material:alien_sand", "alien_material:alien_sand"}
	}
})
