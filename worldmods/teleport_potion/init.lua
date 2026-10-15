--[[
	Teleport Potion mod by TenPlus1

	Craft teleport potion or pad, use on node to bookmark location, place to open
	portal or place pad, portals show a blue flame that you can walk into
	before it closes (10 seconds), potions can also be thrown for local teleport.
]]--

-- translation and settings

local S = core.get_translator("teleport_potion")
local mcl = core.get_modpath("mcl_core")
local dist = tonumber(core.settings:get("map_generation_limit") or 31000)
local use_protection = core.settings:get_bool("teleport_potion_enable_protection")

-- creative check

local creative_mode_cache = core.settings:get_bool("creative_mode")

local function is_creative(name)
	return creative_mode_cache or core.check_player_privs(name, {creative = true})
end

-- choose texture for teleport pad

local teleport_pad_texture = "teleport_potion_pad.png"

if core.settings:get_bool("teleport_potion_use_old_texture") == true then
	teleport_pad_texture = "teleport_potion_pad_v1.png"
end

-- make sure coordinates are valid

local function check_coordinates(str)

	if not str or str == "" then return nil end

	-- get coords from string
	local x, y, z = string.match(str, "^(-?%d+),(-?%d+),(-?%d+)$")

	-- check coords
	if x == nil or string.len(x) > 6
	or y == nil or string.len(y) > 6
	or z == nil or string.len(z) > 6 then return end

	-- convert string coords to numbers
	x = tonumber(x) ; y = tonumber(y) ; z = tonumber(z)

	-- are coords in map range ?
	if x > dist or x < -dist or y > dist or y < -dist or z > dist or z < -dist then
		return
	end

	-- return ok coords
	return {x = x, y = y, z = z}
end

-- particle effect

local function effect(pos, amount, texture, min_size, max_size, radius, gravity, glow)

	radius = radius or 2
	gravity = gravity or -10

	core.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = -radius, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size or 0.5,
		maxsize = max_size or 1.0,
		texture = texture,
		glow = glow
	})
end

-- position bookmark function

local teleport_destinations = {}

local function set_teleport_destination(playername, dest)

	if use_protection and core.is_protected(dest, playername) then
		core.chat_send_player(playername, S("Destination protected!")) ; return
	end

	teleport_destinations[playername] = dest

	effect(dest, 20, "teleport_potion_particle.png", 0.5, 1.5, 1, 7, 15)

	core.sound_play("portal_open", {
			pos = dest, gain = 1.0, max_hear_distance = 10}, true)
end

--- Teleport portal

core.register_node("teleport_potion:portal", {
	drawtype = "plantlike",
	tiles = {
		{
			name = "teleport_potion_portal.png",
			animation = {
				type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.0
			}
		}
	},
	light_source = 13,
	walkable = false,
	paramtype = "light",
	pointable = false,
	buildable_to = true,
	waving = 1,
	sunlight_propagates = true,
	damage_per_second = 1, -- walking into portal hurts player
	groups = {not_in_creative_inventory = 1},
	drop = {},

	-- start timer when portal appears
	on_construct = function(pos)
		core.get_node_timer(pos):start(10)
	end,

	-- remove portal after 10 seconds
	on_timer = function(pos)

		core.sound_play("portal_close", {
				pos = pos, gain = 1.0, max_hear_distance = 10}, true)

		effect(pos, 25, "teleport_potion_particle.png", 2, 2, 1, -10, 15)

		core.remove_node(pos)
	end,

	on_blast = function() end,
})

-- Throwable potion

local function throw_potion(itemstack, player)

	local pos = player:get_pos()
	local prop = player:get_properties()
	local y_off = prop.eye_height or 1.5

	local obj = core.add_entity({
		x = pos.x,
		y = pos.y + y_off,
		z = pos.z
	}, "teleport_potion:potion_entity")

	local dir = player:get_look_dir()
	local velocity = 20

	obj:set_velocity({x = dir.x * velocity, y = dir.y * velocity, z = dir.z * velocity})
	obj:set_acceleration({x = dir.x * -3, y = -9.5, z = dir.z * -3})
	obj:set_yaw(player:get_look_horizontal())
	obj:get_luaentity().player = player
end

-- potion entity

local potion_entity = {

	initial_properties = {
		physical = true, static_save = false, pointable = false,
		visual = "sprite",
		visual_size = {x = 1.0, y = 1.0},
		textures = {"teleport_potion_potion.png"},
		collisionbox = {-0.2,-0.2,-0.2,0.2,0.2,0.2},
	},
	player = ""
}

potion_entity.on_step = function(self, dtime, moveresult)

	if not self.player or self.player == "" then
		self.object:remove() ; return
	end

	if moveresult.collides then

		-- round up coords to fix glitching through doors
		local pos = vector.round(self.object:get_pos())
		local oldpos = self.player:get_pos()

		-- if we hit a player or mob then switch positions
		local def = moveresult.collisions and moveresult.collisions[1] or {}
		local playername = self.player:get_player_name() or ""

		-- if protection enabled check if we can teleport or drop potion
		if use_protection and core.is_protected(pos, playername) then

			core.chat_send_player(playername, S("Destination protected!"))
			core.add_item(pos, "teleport_potion:potion")

			self.object:remove() ; return
		end

		if def.object then
			def.object:set_pos(oldpos)
		end

		-- play sound and disappearing particle effect at current position
		core.sound_play("portal_close", {
				pos = oldpos, gain = 1.0, max_hear_distance = 7}, true)

		effect(oldpos, 25, "teleport_potion_particle.png", 2, 2, 1, -10, 15)

		-- teleport to new position, play sound and show appear effect
		self.player:set_pos(pos)

		core.sound_play("portal_close", {
				pos = pos, gain = 1.0, max_hear_distance = 7}, true)

		effect(pos, 20, "teleport_potion_particle.png", 2, 2, 1, 10, 15)

		self.object:remove()
	end
end

core.register_entity("teleport_potion:potion_entity", potion_entity)

--- Teleport potion

core.register_node("teleport_potion:potion", {
	tiles = {"teleport_potion_potion.png"},
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	description = S("Teleport Potion (use to set destination, place to open portal)"),
	inventory_image = "teleport_potion_potion.png",
	wield_image = "teleport_potion_potion.png",
	groups = {dig_immediate = 3, vessel = 1},
	selection_box = {type = "wallmounted"},

	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type == "node" then
			set_teleport_destination(user:get_player_name(), pointed_thing.above)
		else
			throw_potion(itemstack, user)

			if not is_creative(user:get_player_name()) then

				itemstack:take_item()

				return itemstack
			end
		end
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)

		local name = placer:get_player_name()
		local dest = teleport_destinations[name]

		if dest then

			core.set_node(pos, {name = "teleport_potion:portal"})

			local meta = core.get_meta(pos)

			-- Set portal destination
			meta:set_int("x", dest.x)
			meta:set_int("y", dest.y)
			meta:set_int("z", dest.z)

			-- Portal open effect and sound
			effect(pos, 20, "teleport_potion_particle.png", 0.5, 1.5, 1, 7, 15)

			core.sound_play("portal_open", {
					pos = pos, gain = 1.0, max_hear_distance = 10}, true)
		else
			core.chat_send_player(name, S("Potion failed!"))
			core.remove_node(pos)
			core.add_item(pos, "teleport_potion:potion")
		end
	end
})

-- teleport potion recipe

if mcl then

	core.register_craft({
		output = "teleport_potion:potion",
		recipe = {
			{"", "mcl_core:diamond", ""},
			{"mcl_core:diamond", "mcl_potions:glass_bottle", "mcl_core:diamond"},
			{"", "mcl_core:diamond", ""}
		}
	})
else
	core.register_craft({
		output = "teleport_potion:potion",
		recipe = {
			{"", "default:diamond", ""},
			{"default:diamond", "vessels:glass_bottle", "default:diamond"},
			{"", "default:diamond", ""}
		}
	})
end

--- Teleport pad

local teleport_formspec_context = {}

core.register_node("teleport_potion:pad", {
	tiles = {teleport_pad_texture, teleport_pad_texture .. "^[transformFY"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = true,
	sunlight_propagates = true,
	description = S("Teleport Pad (use to set destination, place to open portal)"),
	inventory_image = teleport_pad_texture,
	wield_image = teleport_pad_texture,
	light_source = 5,
	groups = {snappy = 3},
	node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}},
	selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}},

	-- Save pointed nodes coordinates as destination for further portals
	on_use = function(itemstack, user, pointed_thing)

		if pointed_thing.type == "node" then
			set_teleport_destination(user:get_player_name(), pointed_thing.above)
		end
	end,

	-- Initialize teleport to saved location or the current position
	after_place_node = function(pos, placer, itemstack, pointed_thing)

		local meta = core.get_meta(pos)
		local name = placer:get_player_name()
		local dest = teleport_destinations[name]

		if not dest then dest = pos end

		-- Set coords
		meta:set_int("x", dest.x)
		meta:set_int("y", dest.y)
		meta:set_int("z", dest.z)

		meta:set_string("infotext", S("Pad Active (@1,@2,@3)", dest.x, dest.y, dest.z))

		effect(pos, 20, "teleport_potion_particle.png", 0.5, 1.5, 1, 7, 15)

		core.sound_play("portal_open", {
				pos = pos,	 gain = 1.0, max_hear_distance = 10}, true)
	end,

	-- Show formspec depending on the players privileges.
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

		local name = clicker:get_player_name()

		if core.is_protected(pos, name) then

			core.record_protection_violation(pos, name)

			return
		end

		local meta = core.get_meta(pos)
		local coords = meta:get_int("x") .. ","
				.. meta:get_int("y") .. "," .. meta:get_int("z")
		local desc = meta:get_string("desc")
		local formspec = "field[desc;" .. S("Description") .. ";"
				.. core.formspec_escape(desc) .. "]"

		-- Only allow privileged players to change coordinates
		if core.check_player_privs(name, "teleport") then
			formspec = formspec ..
					"field[coords;" .. S("Teleport coordinates") .. ";" .. coords .. "]"
		end

		teleport_formspec_context[name] = {pos = pos, coords = coords, desc = desc}

		core.show_formspec(name, "teleport_potion:set_destination", formspec)
	end
})

-- Check and set coordinates

core.register_on_player_receive_fields(function(player, formname, fields)

	if formname ~= "teleport_potion:set_destination" then return false end

	local name = player:get_player_name()
	local context = teleport_formspec_context[name]

	if not context then return false end

	teleport_formspec_context[name] = nil

	if fields.control == nil and fields.desc == nil then return false end

	local meta = core.get_meta(context.pos)

	-- Coordinates were changed
	if fields.coords and fields.coords ~= context.coords then

		local coords = check_coordinates(fields.coords)

		if coords then
			meta:set_int("x", coords.x)
			meta:set_int("y", coords.y)
			meta:set_int("z", coords.z)
		else
			core.chat_send_player(name, S("Teleport Pad coordinates failed!"))
		end
	end

	-- Update infotext
	if fields.desc then
		meta:set_string("desc", fields.desc)
	end

	if fields.desc and fields.desc ~= "" then
		meta:set_string("infotext", S("Teleport to @1", fields.desc))
	else
		local coords = core.string_to_pos("(" .. context.coords .. ")")

		meta:set_string("infotext", S("Pad Active (@1,@2,@3)",
			coords.x, coords.y, coords.z))
	end

	return true
end)

-- teleport pad recipe

if mcl then

	core.register_craft({
		output = "teleport_potion:pad",
		recipe = {
			{"teleport_potion:potion", "mcl_core:glass", "teleport_potion:potion"},
			{"mcl_core:glass", "mesecons:redstone", "mcl_core:glass"},
			{"teleport_potion:potion", "mcl_core:glass", "teleport_potion:potion"}
		}
	})
else
	core.register_craft({
		output = "teleport_potion:pad",
		recipe = {
			{"teleport_potion:potion", "default:glass", "teleport_potion:potion"},
			{"default:glass", "default:mese", "default:glass"},
			{"teleport_potion:potion", "default:glass", "teleport_potion:potion"}
		}
	})
end

-- check portal & pad, teleport any entities on top

core.register_abm({
	label = "Potion/Pad teleportation",
	nodenames = {"teleport_potion:portal", "teleport_potion:pad"},
	interval = 2,
	chance = 1,
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)

		-- check objects inside pad/portal
		local objs = core.get_objects_inside_radius(pos, 1)

		if #objs == 0 then return end

		-- get coords from pad/portal
		local meta = core.get_meta(pos)

		if not meta then return end -- errorcheck

		local target_coords = {
			x = meta:get_int("x"),
			y = meta:get_int("y"),
			z = meta:get_int("z")
		}

		for n = 1, #objs do

			-- are we a player who isn't currently attached?
			if objs[n]:is_player() and not objs[n]:get_attach() then

				-- play sound on portal end
				core.sound_play("portal_close", {
						pos = pos, gain = 1.0, max_hear_distance = 5}, true)

				pos.y = pos.y + 1

				-- particle effect on disappear
				effect(pos, 25, "teleport_potion_particle.png", 2, 2, 1, -10, 15)

				-- move player
				objs[n]:set_pos(target_coords)

				-- paricle effects on arrival
				effect(target_coords, 20, "teleport_potion_particle.png", 2, 2, 1, 10, 15)

				-- play sound on destination end
				core.sound_play("portal_close", {
						pos = target_coords, gain = 1.0, max_hear_distance = 5}, true)

				-- rotate player to look in pad placement direction
				local rot = node.param2
				local yaw = 0

				if rot == 0 or rot == 20 then		yaw = 0 -- north
				elseif rot == 2 or rot == 22 then	yaw = 3.14 -- south
				elseif rot == 1 or rot == 23 then	yaw = 4.71 -- west
				elseif rot == 3 or rot == 21 then	yaw = 1.57 -- east
				end

				objs[n]:set_look_horizontal(yaw)
			end
		end
	end
})

-- lucky blocks

if core.get_modpath("lucky_block") then

	lucky_block:add_blocks({
		{"dro", {"teleport_potion:potion"}, 2},
		{"tel"},
		{"dro", {"teleport_potion:pad"}, 1},
		{"lig"}
	})
end


print ("[MOD] Teleport Potion loaded")
