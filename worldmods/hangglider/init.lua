hangglider = {
	translator = core.get_translator("hangglider"),
}
local S = hangglider.translator

local has_player_monoids = core.get_modpath("player_monoids")
local has_pova = core.get_modpath("pova")
local has_areas = core.get_modpath("areas")

local enable_hud_overlay = core.settings:get_bool("hangglider.enable_hud_overlay", true)
local enable_flak = has_areas and core.settings:get_bool("hangglider.enable_flak", true)
local flak_warning_time = tonumber(core.settings:get("hangglider.flak_warning_time")) or 2
local hangglider_uses = tonumber(core.settings:get("hangglider.uses")) or 250

local flak_warning = S(
	"You have entered restricted airspace!@n" ..
	"You will be shot down in @1 seconds by anti-aircraft guns!",
	flak_warning_time
)

local hanggliding_players = {}
local physics_overrides = {}
local hud_overlay_ids = {}

-------------------------------------------------
-- HUD
-------------------------------------------------
local function set_hud_overlay(player, name, show)
	if not enable_hud_overlay then return end
	if show and not hud_overlay_ids[name] then
		hud_overlay_ids[name] = player:hud_add({
			[core.features.hud_def_type_field and "type" or "hud_elem_type"] = "image",
			text = "hangglider_overlay.png",
			position = {x = 0, y = 0},
			scale = {x = -100, y = -100},
			alignment = {x = 1, y = 1},
			z_index = -150
		})
	elseif not show and hud_overlay_ids[name] then
		player:hud_remove(hud_overlay_ids[name])
		hud_overlay_ids[name] = nil
	end
end

-------------------------------------------------
-- Physics overrides (SAFE)
-------------------------------------------------
local function set_physics_overrides(player, overrides)
	local player_name = player:get_player_name()

	if has_player_monoids then
		for name, value in pairs(overrides) do
			player_monoids[name]:add_change(player, value, "hangglider:glider")
		end

	elseif has_pova then
		pova.add_override(player_name, "hangglider:glider", {
			jump = overrides.jump,
			speed = overrides.speed,
			gravity = overrides.gravity
		})
		pova.do_override(player)

	else
		player:set_physics_override({
			speed = overrides.speed or 1,
			jump = overrides.jump or 1,
			gravity = overrides.gravity or 1
		})
	end
end

local function remove_physics_overrides(player)
	local player_name = player:get_player_name()

	if has_player_monoids then
		for _, name in pairs({"jump", "speed", "gravity"}) do
			player_monoids[name]:del_change(player, "hangglider:glider")
		end

	elseif has_pova then
		pova.del_override(player_name, "hangglider:glider")
		pova.do_override(player)

	else
		player:set_physics_override({speed = 1, jump = 1, gravity = 1})
	end
end

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function can_fly(pos, name)
	if not enable_flak then return true end
	local owners = {}
	for _, area in pairs(areas:getAreasAtPos(pos)) do
		if area.flak then
			owners[area.owner] = true
		end
	end
	return not next(owners) or owners[name]
end

local function safe_node_below(pos)
	local node = core.get_node_or_nil({x = pos.x, y = pos.y - 0.5, z = pos.z})
	if not node then return false end
	local def = core.registered_nodes[node.name]
	return def and def.walkable
end

local function shoot_flak_sound(pos)
	core.sound_play("hangglider_flak_shot", {
		pos = pos,
		max_hear_distance = 30,
		gain = 10,
	}, true)
end

-------------------------------------------------
-- Entity step (FIXED)
-------------------------------------------------
local function hangglider_step(self, dtime)
	local player = self.object:get_attach("parent")
	if not player then
		self.object:remove()
		return
	end

	local name = player:get_player_name()
	if not hanggliding_players[name] then
		self.object:remove()
		return
	end

	local pos = player:get_pos()
	local vel = player:get_velocity()

	-- Flak
	if not can_fly(pos, name) then
		self.flak_timer = (self.flak_timer or 0) + dtime
		if self.flak_timer == dtime then
			shoot_flak_sound(pos)
			core.chat_send_player(name, flak_warning)
		end
		if self.flak_timer > flak_warning_time then
			player:set_hp(1, {type = "set_hp", cause = "hangglider:flak"})
			player:get_inventory():remove_item("main", "hangglider:hangglider")
			hanggliding_players[name] = nil
			remove_physics_overrides(player)
			set_hud_overlay(player, name, false)
			self.object:remove()
			return
		end
	end

	-- Glide physics
	if not safe_node_below(pos) then
		set_physics_overrides(player, {
			speed = 1,        -- disables fast
			jump = 0,
			gravity = 0.85
		})

		-- Clamp velocity (CRITICAL FIX)
		if vel.y < -3 then
			player:set_velocity({x = vel.x, y = -3, z = vel.z})
		end

		local max_speed = 25
		if vector.length(vel) > max_speed then
			player:set_velocity(vector.multiply(vector.normalize(vel), max_speed))
		end
	else
		-- Landed
		hanggliding_players[name] = nil
		remove_physics_overrides(player)
		set_hud_overlay(player, name, false)
		self.object:remove()
	end
end

-------------------------------------------------
-- Tool use
-------------------------------------------------
local function hangglider_use(stack, player)
	if type(player) ~= "userdata" then return end

	local name = player:get_player_name()
	local pos = player:get_pos()

	if hanggliding_players[name] then
		hanggliding_players[name] = nil
		remove_physics_overrides(player)
		set_hud_overlay(player, name, false)
		return stack
	end

	core.sound_play("hanggliger_equip", {pos = pos, gain = 1}, true)

	local ent = core.add_entity(pos, "hangglider:glider")
	if not ent then return end

	ent:set_attach(player, "", {x = 0, y = 10, z = 0}, {x = 0, y = 0, z = 0})
	set_hud_overlay(player, name, true)

	set_physics_overrides(player, {jump = 0, gravity = 0.85})
	hanggliding_players[name] = true

	if hangglider_uses > 0 then
		stack:add_wear(65535 / hangglider_uses)
	end

	return stack
end

-------------------------------------------------
-- Cleanup
-------------------------------------------------
core.register_on_dieplayer(function(player)
	hanggliding_players[player:get_player_name()] = nil
	remove_physics_overrides(player)
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	hanggliding_players[name] = nil
	hud_overlay_ids[name] = nil
	remove_physics_overrides(player)
end)

core.register_on_player_hpchange(function(player, hp_change, reason)
	if hanggliding_players[player:get_player_name()] and reason.type == "fall" then
		return 0, true
	end
	return hp_change
end, true)

-------------------------------------------------
-- Entity
-------------------------------------------------
core.register_entity("hangglider:glider", {
	initial_properties = {
		visual = "mesh",
		mesh = "hangglider.obj",
		visual_size = {x = 12, y = 12},
		collisionbox = {0,0,0,0,0,0},
		textures = {xcompat.textures.wool.white, xcompat.textures.wood.apple.planks},
		immortal = true,
		static_save = false,
	},
	on_step = hangglider_step,
})

-------------------------------------------------
-- Tool
-------------------------------------------------
core.register_tool("hangglider:hangglider", {
	description = S("Glider (Immune falling damage)"),
	inventory_image = "hangglider_item.png",
	sound = {breaks = "default_tool_breaks"},
	on_use = hangglider_use,
})

dofile(core.get_modpath("hangglider") .. "/crafts.lua")