--[[

Copyright (C) 2015 - Auke Kok <sofar@foo-projects.org>

"comod_inspector" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

-- TRACK WHO PLACED NODES
minetest.register_on_placenode(function(pos, newnode, placer)
	if not placer or not placer:is_player() then
		return
	end

	local meta = minetest.get_meta(pos)
	meta:set_string("placed_by", placer:get_player_name())
	meta:set_int("placed_at", os.time())
end)

-- FORMSPEC HELPER
local function make_fs(title, desc)
	return "size[12,8]"..
		"label[0.2,0.2;"..title.."]"..
		"textlist[0.2,1.0;11.5,7;;"..desc:gsub("\n", ",").."]"..
		"button_exit[11.1,0.2;0.8,0.8;close;x]"
end

-- INSPECT A POSITION
local function inspect_pos(pos)
	local node = minetest.get_node(pos)
	local desc = "===== node data =====\n"
	desc = desc .. "name = " .. node.name .. "\n"
	desc = desc .. "param1 = " .. node.param1 .. "\n"
	desc = desc .. "param2 = " .. node.param2 .. "\n"

	local light = minetest.get_node_light({x=pos.x, y=pos.y+1, z=pos.z}, nil)
	if light then
		desc = desc .. "light = " .. light .. "\n"
	end

	local timer = minetest.get_node_timer(pos)
	if timer:get_timeout() ~= 0 then
		desc = desc .. "==== node timer ====\n"
		desc = desc .. "timeout = " .. timer:get_timeout() .. "\n"
		desc = desc .. "elapsed = " .. timer:get_elapsed() .. "\n"
	end

	local meta = minetest.get_meta(pos)
	local t = meta:to_table()
	local fields = minetest.serialize(t.fields)

	-- OWNER INFO
	local owner = t.fields.placed_by
	local placed_at = tonumber(t.fields.placed_at)
	desc = desc .. "==== ownership ====\n"
	if owner and owner ~= "" then
		desc = desc .. "placed_by = " .. owner .. "\n"
	else
		desc = desc .. "placed_by = <unknown>\n"
	end
	if placed_at then
		desc = desc .. "placed_at = " .. os.date("%Y-%m-%d %H:%M:%S", placed_at) .. "\n"
	else
		desc = desc .. "placed_at = <unknown>\n"
	end
	desc = desc .. "\n"

	-- META
	desc = desc .. "==== meta ====\n"
	desc = desc .. "meta.fields = " .. fields .. "\n\n"

	-- INVENTORY
	local inv = meta:get_inventory()
	desc = desc .. "meta.inventory = \n"
	for key, list in pairs(inv:get_lists()) do
		desc = desc .. key .. ":\n"
		for i=1,#list do
			local stack = list[i]
			if not stack:is_empty() then
				desc = desc .. "\"" .. stack:get_name() .. "\" - " .. stack:get_count() .. "\n"
			end
		end
	end

	-- NODEDEF
	local nodedef = minetest.registered_items[node.name]
	if nodedef then
		desc = desc .. "==== nodedef ====\n"
		desc = desc .. dump(nodedef) .. "\n"
	end

	return minetest.formspec_escape(desc:gsub(",", "\\,"))
end

-- INSPECTOR TOOL
minetest.register_tool("comod_inspector:inspector", {
	description = "Inspector Tool",
	inventory_image = "inspector.png",
	liquids_pointable = true,

	on_use = function(_, user, pointed_thing)
		if pointed_thing.type == "nothing" then return end

		local title, desc = "", ""
		if pointed_thing.type == "node" then
			title = "Node information"
			desc = inspect_pos(pointed_thing.under)
		elseif pointed_thing.type == "object" then
			title = "Object information"
			local ref = pointed_thing.ref
			local ent = ref and ref:get_luaentity()
			if ent then
				desc = minetest.formspec_escape(dump(ent):gsub("\n\n", "\n"))
			end
		end

		minetest.show_formspec(
			user:get_player_name(),
			"comod_inspector:inspector",
			make_fs(title, desc)
		)
	end,
})

-- CHAT COMMAND
minetest.register_chatcommand("inspect", {
	params = "<x> <y> <z>",
	description = "Inspect a node position",
	privs = {server = true},

	func = function(name, param)
		local p = {}
		for v in param:gmatch("[^%s]+") do
			table.insert(p, tonumber(v))
		end
		if #p ~= 3 then
			return false, "Usage: /inspect <x> <y> <z>"
		end

		local pos = {x=p[1], y=p[2], z=p[3]}
		local desc = inspect_pos(pos)

		minetest.show_formspec(
			name,
			"comod_inspector:inspector",
			make_fs("Node information", desc)
		)
		return true
	end,
})
