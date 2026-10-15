
local S = safe_yourself.translator
local settings = safe_yourself.settings

-- Chat command to respawn player
core.register_chatcommand(settings.respawn_command, {
	params = "",
	description = S("Respawn yourself if you are stuck in death"),
	privs = {server=true},
	func = function(player_name, params)
		local player = core.get_player_by_name(player_name)
		if not player then
			return false, S("Player not found")
		end
		
		player:respawn()
		return true, S("You have been respawned")
	end,
})

-- Chat command to set HP to 1 if player has 0 HP
core.register_chatcommand(settings.one_hp_command, {
	params = "",
	description = S("Set your HP to 1 if you have 0 HP"),
	privs = {},
	func = function(player_name, params)
		local player = core.get_player_by_name(player_name)
		if not player then
			return false, S("Player not found")
		end
		
		local hp = player:get_hp()
		if hp == 0 then
			player:set_hp(1)
			return true, S("Your HP has been set to 1")
		else
			return false, S("You already have HP: @1", hp)
		end
	end,
})