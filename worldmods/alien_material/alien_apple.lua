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
	Alien apples
]]--

alien_material.PLAYER_MAX_ALIENHP_DEFAULT = 20
alien_material.registered_on_player_alienhpchange = {}

local S = alien_material.S

local alien_apple_granted_hearts = minetest.settings:get("alien_material.alien_apple_granted_hearts") or 4

local offset_completion = 22
if minetest.get_modpath("stamina") then
	offset_completion = offset_completion + 22
end

local alien_bar_definition = {
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	text = "alien_heart.png",
	text2 = "heart_gone.png",
	number = alien_material.PLAYER_MAX_ALIENHP_DEFAULT,
	item = alien_material.PLAYER_MAX_ALIENHP_DEFAULT,
	direction = 0,
	size = {x = 22, y = 22},
	offset = {x = (-10 * 24) - 25, y = -(48 + 24 + 16 + offset_completion)},
}

local hud_ids = {}
local function update_alienhp_hud(player) end

-- ### alienhearts ###

-- Here is the function which writes the alienhp in the meta

local function meta_write_alienhp(player, value)
	if player.get_meta then
		local meta = player:get_meta()
		if meta and value == nil then
			meta:set_int("alienhp", 0)
		elseif meta then
			meta:set_int("alienhp", tonumber(value))
		end
	end
end

-- Here you get the alienhp of a player
function alien_material.get_alienhp(player)
	if player.get_meta then
		local meta = player:get_meta()
		return meta and meta:get_int("alienhp") or 0
	end
end

-- Here you set the alienhp of a player
function alien_material.set_alienhp(player, value, reason)
	reason = reason or "set_hp"
	if value > alien_material.PLAYER_MAX_ALIENHP_DEFAULT then value = 20 elseif value < 0 then value = 0 end -- Only
	for _, callback in pairs(alien_material.registered_on_player_alienhpchange) do
		if callback.modifier then
			local stopexe
			value, stopexe = callback.func(player, value - alien_material.get_alienhp(player), reason)
			value = value + alien_material.get_alienhp(player)
			print(stopexe)
			if stopexe then break end
		else
			callback.func(player, value - alien_material.get_alienhp(player), reason)
		end
	end
	meta_write_alienhp(player, value)
	update_alienhp_hud(player)
end

-- Callback
-- Inspired how callbacks are done in arena_lib, https://gitlab.com/zughy-friends-minetest/arena_lib/-/blob/master/src/callbacks.lua

function alien_material.register_on_player_alienhpchange(func, modifier) -- Do same as minetest.register_on_player_hpchange() but with alienhp but all modigiers are executed
	modifier = modifier or false
	table.insert(alien_material.registered_on_player_alienhpchange, {["func"] = func, ["modifier"] = modifier})
end

-- Misc

-- Use this function for give the player alienhp like wanted
function alien_material.grant_alienhp(player, value)
	if alien_material.get_alienhp(player) >= value then return end
	alien_material.set_alienhp(player, value)
end

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason == "set_hp" then return hp_change end --At this reasons the Alienapple can't help. More can added in future…
	if hp_change >= 0 then return hp_change end
	local alienhp = alien_material.get_alienhp(player)
	if alienhp == 0 then return hp_change end
	if alienhp + hp_change >= 0 then
		alien_material.set_alienhp(player, alienhp + hp_change)
		return 0
	elseif alienhp + hp_change < 0 then
		alien_material.set_alienhp(player, 0)
		return alienhp + hp_change
	end
end, true)


-- ### Huds ###

function update_alienhp_hud(player)
	local p_name = player:get_player_name()
	player:hud_change(hud_ids[p_name], "number", alien_material.get_alienhp(player))
end

minetest.register_on_joinplayer(function(player)
	hud_ids[player:get_player_name()] = player:hud_add(alien_bar_definition)
	update_alienhp_hud(player)
end)

minetest.register_on_leaveplayer(function(player)
	local p_name = player:get_player_name()
	if name == "" then
		return
	end
	hud_ids[p_name] = nil
end)

-- ### Items ###

minetest.register_node("alien_material:alien_apple", {
	description = S("Alien apple"),
	drawtype = "plantlike",
	tiles = {"alien_apple.png"},
	inventory_image = "alien_apple.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-3 / 16, -7 / 16, -3 / 16, 3 / 16, 4 / 16, 3 / 16}
	},
	groups = {fleshy = 3, dig_immediate = 3,},
	on_use = function(itemstack, player, pointed_thing)
		alien_material.grant_alienhp(player, alien_apple_granted_hearts)
		minetest.do_item_eat(20, nil, itemstack, player, pointed_thing)
	end,
	sounds = default.node_sound_leaves_defaults(),
})
