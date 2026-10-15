minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	if meta:get_string("player_already_joined") ~= "true" then
		player:set_pos({x = 3111, y = 42, z = -4235})
		meta:set_string("player_already_joined", "true")
	end
end)
