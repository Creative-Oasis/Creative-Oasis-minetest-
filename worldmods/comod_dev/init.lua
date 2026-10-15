comod_dev = {}
comod_dev.storage = minetest.get_mod_storage()

-- ======================
-- Privilege
-- ======================
minetest.register_privilege("comod_dev", {
	description = "Access comod_dev developer tools",
	give_to_singleplayer = true,
})

local function is_dev(name)
	return minetest.check_player_privs(name, { comod_dev = true })
end

-- ======================
-- Storage default
-- ======================
if comod_dev.storage:get_string("auto_detect") == "" then
	comod_dev.storage:set_string("auto_detect", "off")
end

-- ======================
-- Client classification
-- ======================
local function classify_client(info)
	if not info or not info.version_string or info.version_string == "" then
		return "Unknown Client"
	end

	local vs = info.version_string
	local vs_l = vs:lower()
	local proto = info.protocol_version or 0

	-- Known suspicious / modified patterns
	if vs_l:find("hack") or vs_l:find("cheat") or vs_l:find("custom") or vs_l:find("dev") then
		return "Modified " .. vs
	end

	-- Protocol mismatch (very old or invalid)
	if proto > 0 and proto < 46 then
		return "Modified " .. vs
	end

	-- Default
	return "Luanti " .. vs
end

-- ======================
-- Client info helper
-- ======================
local function get_client_info(name)
	local info = minetest.get_player_information(name)
	if not info then
		return {
			client   = "Unknown Client",
			protocol = "Unknown",
			formspec = "Unknown",
			lang     = "Unknown",
		}
	end

	return {
		client   = classify_client(info),
		protocol = info.protocol_version and tostring(info.protocol_version) or "Unknown",
		formspec = info.formspec_version and tostring(info.formspec_version) or "Unknown",
		lang     = (info.lang_code and info.lang_code ~= "") and info.lang_code or "Unknown",
	}
end

-- ======================
-- Colors
-- ======================
local GREY   = "#AAAAAA"
local ORANGE = "#FFAA00"
local YELLOW = "#FFD700"
local RED    = "#FF5555"

local function color_client(value)
	if value:find("Unknown") then
		return minetest.colorize(ORANGE, value)
	elseif value:find("Modified") then
		return minetest.colorize(YELLOW, value)
	elseif value:find("Suspicious") then
		return minetest.colorize(RED, value)
	else
		return minetest.colorize(GREY, value)
	end
end

local function color_value(value)
	if value == "Unknown" then
		return minetest.colorize(ORANGE, value)
	end
	return minetest.colorize(GREY, value)
end

-- ======================
-- Formatter 
-- ======================
local function format_client_info(info)
	return
		minetest.colorize(GREY, "Client: ") .. color_client(info.client) ..
		minetest.colorize(GREY, " | Protocol: ") .. color_value(info.protocol) ..
		minetest.colorize(GREY, " | Formspec: ") .. color_value(info.formspec) ..
		minetest.colorize(GREY, " | Lang: ") .. color_value(info.lang)
end

-- ======================
-- Auto detect on join
-- ======================
minetest.register_on_joinplayer(function(player)
	if comod_dev.storage:get_string("auto_detect") ~= "on" then
		return
	end

	local pname = player:get_player_name()
	local info = get_client_info(pname)

	for _, p in ipairs(minetest.get_connected_players()) do
		local devname = p:get_player_name()
		if is_dev(devname) then
			minetest.chat_send_player(
				devname,
				"🛠️ [comod_dev] " .. pname .. " joined | " .. format_client_info(info)
			)
		end
	end
end)

-- ======================
-- Chat command
-- ======================
minetest.register_chatcommand("comod_dev", {
	params = "auto_client_detect on|off | client_detect <player>",
	description = "Developer client detection tools",
	privs = { comod_dev = true },

	func = function(name, param)
		local args = param:split(" ")

		-- Toggle auto detect
		if args[1] == "auto_client_detect" then
			if args[2] ~= "on" and args[2] ~= "off" then
				return false, "Usage: /comod_dev auto_client_detect on|off"
			end

			comod_dev.storage:set_string("auto_detect", args[2])
			return true, "✅ Auto client detect set to: " .. args[2]
		end

		-- Manual detect
		if args[1] == "client_detect" and args[2] then
			local target = args[2]

			if not minetest.get_player_by_name(target) then
				return false, "❌ Player is not online"
			end

			local info = get_client_info(target)
			minetest.chat_send_player(
				name,
				"🧪 [comod_dev] " .. target .. " | " .. format_client_info(info)
			)

			return true, "ℹ️ Client info shown above"
		end

		return false,
			"Usage:\n" ..
			"/comod_dev auto_client_detect on|off\n" ..
			"/comod_dev client_detect <player>"
	end
})

minetest.log("action",
	"[comod_dev] Loaded | Auto detect: " ..
	comod_dev.storage:get_string("auto_detect")
)
