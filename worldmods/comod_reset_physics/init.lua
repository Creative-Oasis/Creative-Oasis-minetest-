minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if name == "Anastasiya" then
        -- Reset only once when joining
        player:set_physics_override({speed=1, jump=1, gravity=1})
    end
end)
