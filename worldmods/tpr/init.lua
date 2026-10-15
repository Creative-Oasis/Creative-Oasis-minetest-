--[[
Allows players to request from another player to be teleported to them.
Includes many more teleporting features. Built for Minetest.

Copyright (C) 2014-2024 ChaosWormz and contributors
LGPL-2.1-or-later
--]]

local MP = minetest.get_modpath(minetest.get_current_modname())
local S  = minetest.get_translator(minetest.get_current_modname())

tp = {
	S = S,

	tpr_list = {},
	tphr_list = {},
	tpc_list = {},
	tpn_list = {},
	tpf_update_time = {},

	-- cooldowns ONLY for tpr / tphr
	-- cooldowns[from][to][cmd] = unix_time
	request_cooldowns = {},
}

----------------------------------------------------------------
-- cooldown helpers (tpr + tphr only)
----------------------------------------------------------------

local function now()
	return os.time()
end

local VALID_CMDS = {
	tpr  = true,
	tphr = true,
}

function tp.format_time(seconds)
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return m .. " min " .. s .. " s"
end

function tp.can_send_request(from, to, cmd)
	if not VALID_CMDS[cmd] then
		return true -- tpn / tpc ignored
	end

	local f = tp.request_cooldowns[from]
	if not f then return true end

	local t = f[to]
	if not t then return true end

	local c = t[cmd]
	if not c then return true end

	return now() >= c
end

function tp.set_cooldown(from, to, cmd, seconds)
	if not VALID_CMDS[cmd] then
		return
	end

	tp.request_cooldowns[from] = tp.request_cooldowns[from] or {}
	tp.request_cooldowns[from][to] = tp.request_cooldowns[from][to] or {}
	tp.request_cooldowns[from][to][cmd] = now() + seconds
end

function tp.cooldown_left(from, to, cmd)
	if not VALID_CMDS[cmd] then return 0 end

	local f = tp.request_cooldowns[from]
	if not f or not f[to] or not f[to][cmd] then return 0 end

	return math.max(0, f[to][cmd] - now())
end

----------------------------------------------------------------
-- Clear requests + cooldowns when player leaves
----------------------------------------------------------------

minetest.register_on_leaveplayer(function(name)
	tp.tpr_list[name]  = nil
	tp.tphr_list[name] = nil
	tp.tpc_list[name]  = nil
	tp.tpn_list[name]  = nil
	tp.request_cooldowns[name] = nil
end)

----------------------------------------------------------------
-- Load other files
----------------------------------------------------------------

dofile(MP .. "/privileges.lua")
dofile(MP .. "/config.lua")
dofile(MP .. "/functions.lua")
dofile(MP .. "/commands.lua")

----------------------------------------------------------------
-- Log
----------------------------------------------------------------

if minetest.settings:get_bool("log_mods") then
	minetest.log("action",
		"[MOD] Teleport Request v" .. (tp.version or "?") .. " loaded!")
end
