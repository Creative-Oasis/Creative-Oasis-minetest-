minetest.register_privilege("comod_fsay", {
	description = "Can use /fsay to send global messages",
	give_to_singleplayer = true
})

local COLORS = {
	red     = "#ff0000",
	green   = "#00ff00",
	blue    = "#0000ff",
	yellow  = "#ffff00",
	orange  = "#ff8800",
	purple  = "#aa00ff",
	pink    = "#ff66cc",
	cyan    = "#00ffff",
	white   = "#ffffff",
	black   = "#000000",
	gray    = "#888888"
}

minetest.register_chatcommand("fsay", {
	params = "<color> <text>",
	description = "Send a colored global message",
	privs = { comod_fsay = true },

	func = function(name, param)
		if param == "" then
			return false, "Usage: /fsay <color> <text>"
		end

		local color, text = param:match("^(%S+)%s+(.+)$")
		if not text then
			return false, "Usage: /fsay <color> <text>"
		end

		color = color:lower()

		if not COLORS[color] then
			return false, "You cannot send a chat with unknown color."
		end

		minetest.chat_send_all(
			minetest.colorize(COLORS[color], text)
		)

		return true
	end
})
