--[[
death_messages - A Minetest mod which sends a chat message when a player dies.
Copyright (C) 2016  EvergreenTree

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-----------------------------------------------------------------------------------------------
local title = "Death Messages"
local version = "0.1.2"
local mname = "death_messages"
-----------------------------------------------------------------------------------------------
dofile(minetest.get_modpath("death_messages").."/settings.txt")
-----------------------------------------------------------------------------------------------

-- A table of quips for death messages
local messages = {}

-- Lava death messages
messages.lava = {
	" melted into a ball of fire.",
	" thought lava was cool.",
	" melted into a ball of fire.",
	" couldn't resist that warm glow of lava.",
	" dug straight down.",
	" didn't know lava was hot."
}

-- Drowning death messages
messages.water = {
	" drowned.",
	" ran out of air.",
	" failed at swimming lessons.",
	" tried to impersonate an anchor.",
	" forgot he wasn't a fish.",
	" blew one too many bubbles."
}

-- Burning death messages
messages.fire = {
	" burned to a crisp.",
	" got a little too warm.",
	" got too close to the camp fire.",
	" just got roasted, hotdog style.",
	" gout burned up. More light that way."
}

-- Other death messages
messages.other = {
	" died.",
	" did something fatal.",
	" gave up on life.",
	" is somewhat dead now.",
	" passed out -permanently.",
    " died in a very confusing way.",
	" suddenly remembered they were mortal.",
	" stopped living for reasons best left unknown.",
	" vanished after making a questionable decision.",
	" experienced a fatal oops moment.",
	" met an end nobody saw coming.",
	" discovered the respawn button.",
	" learned that today was not their day.",
	" died doing… something.",
	" randomly ceased all operations.",
	" encountered a surprise death event.",
	" found out the world bites back.",
	" exited life unexpectedly.",
	" suffered from extreme bad luck.",
	" pressed on when they probably shouldn’t have.",
	" had a moment that went very wrong.",
	" learned too late that was a bad idea."
}

function get_message(mtype)
	if RANDOM_MESSAGES then
		return messages[mtype][math.random(1, #messages[mtype])]
	else
		return messages[mtype][1] -- first message if random disabled
	end
end

-- List of colors for messages (hex codes)
local msg_colors = { "#ff5555", "#55ffff", "#ffaa00", "#ff55ff", "#55ff55", "#ffffff" }

minetest.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	local node = minetest.registered_nodes[minetest.get_node(player:getpos()).name]
	if minetest.is_singleplayer() then
		player_name = "You"
	end

	-- Color codes
	local name_color = "#aaff00" -- yellow-green for player name
	local msg_color = msg_colors[math.random(1, #msg_colors)] -- random color
	local msg = ""

	-- Death by lava
	if node.groups.lava ~= nil then
		msg = get_message("lava")
	-- Death by drowning
	elseif player:get_breath() == 0 then
		msg = get_message("water")
	-- Death by fire
	elseif node.name == "fire:basic_flame" then
		msg = get_message("fire")
	-- Death by something else
	else
		msg = get_message("other")
	end

	-- Send colored chat message
	minetest.chat_send_all(
		minetest.colorize(name_color, player_name) ..
		minetest.colorize(msg_color, msg)
	)
end)

-----------------------------------------------------------------------------------------------
print("[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
-----------------------------------------------------------------------------------------------
