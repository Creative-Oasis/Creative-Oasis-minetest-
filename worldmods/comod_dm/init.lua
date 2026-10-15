local C = minetest.colorize
local json = minetest.write_json and minetest or { write_json = function(t, f) return nil end }

-- Colors
local PINK = "#ff69b4"
local LIGHT_GREEN = "#90ee90"
local WHITE = "#ffffff"
local YELLOW = "#ffff55"
local BROWN = "#a0522d"
local RED = "#ff0000"

-- =========================
-- BLOCK STORAGE (per-player)
-- =========================
-- block_map[blocker][blocked] = true
-- Make this global so DM mod can access
block_map = block_map or {}

local function is_blocked(sender, target)
	-- Returns true if sender blocked target OR target blocked sender
	return (block_map[sender] and block_map[sender][target]) or
	       (block_map[target] and block_map[target][sender])
end

-- Optional helpers for other mods
comod_blocks = comod_blocks or {}
function comod_blocks.block(a, b)
	block_map[a] = block_map[a] or {}
	block_map[a][b] = true
end

function comod_blocks.unblock(a, b)
	if block_map[a] then
		block_map[a][b] = nil
	end
end

-- =========================
-- Register staff privilege
-- =========================
minetest.register_privilege("comod_dm", {
	description = "Can toggle DM spying",
	give_to_singleplayer = false,
})

-- =========================
-- File to save DM spy state
-- =========================
local dm_file = minetest.get_worldpath().."/comod_dm.json"
local dm_spy_enabled = {}

-- Load saved DM spy state
local file = io.open(dm_file, "r")
if file then
	local content = file:read("*all")
	local ok, tbl = pcall(minetest.parse_json, content)
	if ok and type(tbl) == "table" then
		dm_spy_enabled = tbl
	end
	file:close()
end

-- Save DM spy state
local function save_dm_spy()
	local f = io.open(dm_file, "w")
	if f then
		f:write(minetest.write_json(dm_spy_enabled))
		f:close()
	end
end

-- =========================
-- /comod_dm toggle
-- =========================
minetest.register_chatcommand("comod_dm", {
	params = "on/off",
	description = "Toggle DM spy visibility (staff only)",
	privs = {comod_dm = true},

	func = function(name, param)
		param = param:lower()
		if param ~= "on" and param ~= "off" then
			return false, "Usage: /comod_dm on|off"
		end

		dm_spy_enabled[name] = (param == "on")
		save_dm_spy()
		return true, "DM spy is now " .. (param == "on" and "ON" or "OFF")
	end
})

-- =========================
-- Override /msg command
-- =========================
minetest.register_chatcommand("msg", {
	params = "<player> <message>",
	description = "Send a private message",
	privs = {shout = true},

	func = function(name, param)
		local target, message = param:match("^(%S+)%s(.+)$")
		if not target or not message then
			return false, "Usage: /msg <player> <message>"
		end

		if target == name then
			return false, "You cannot send a private message to yourself."
		end

		local target_obj = minetest.get_player_by_name(target)
		if not target_obj then
			return false, "Player not online."
		end

		-- =========================
		-- BLOCK CHECKS (integrated)
		-- =========================
		if block_map[name] and block_map[name][target] then
			return false, C(RED, "You blocked them, you cannot send messages to them.")
		end

		if block_map[target] and block_map[target][name] then
			return false, C(RED, "They blocked you, you cannot send messages to them.")
		end

		-- =========================
		-- DM to sender
		-- =========================
		minetest.chat_send_player(name,
			C(PINK, "DM ") ..
			C(WHITE, "sent to ") ..
			C(LIGHT_GREEN, target) ..
			C(WHITE, ": ") ..
			message
		)

		-- =========================
		-- DM to receiver
		-- =========================
		minetest.chat_send_player(target,
			C(PINK, "DM ") ..
			C(YELLOW, "from ") ..
			C(LIGHT_GREEN, name) ..
			C(WHITE, ": ") ..
			message
		)

		-- =========================
		-- DM Spy for staff
		-- =========================
		for _, player in ipairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			if pname ~= name and pname ~= target
				and minetest.check_player_privs(pname, {comod_dm = true})
				and dm_spy_enabled[pname]
			then
				minetest.chat_send_player(pname,
					C(PINK, "[DM SPY] ") ..
					C(BROWN, "(" .. name .. " → " .. target .. ") ") ..
					message
				)
			end
		end

		return true
	end
})
