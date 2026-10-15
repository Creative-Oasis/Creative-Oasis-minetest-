--[[
minetest.register_chatcommand("hello", {
    description = "Say hello!",
    params = "", -- No additional parameters
    func = function(name, param)

        minetest.chat_send_player(name, "Hello, " .. name .. "!")


        local forceloaded_blocks = minetest.forceloaded_blocks

        if forceloaded_blocks then
			-- Iterate through the table and print each block's position and load reason
			for pos, reason in pairs(forceloaded_blocks) do
				local load_reason = reason == minetest.forceload_load_reason.proximity and "Proximity" or "Forced"
				--minetest.log("action", "Block at " .. minetest.pos_to_string(pos) .. " is loaded due to: " .. load_reason)
				print("action", "Block at " .. minetest.pos_to_string(pos) .. " is loaded due to: " .. load_reason)
			end
		else
			print("No force loaded blocks found")
		end

    end,
})
]]
