--override the global function to make minimap and radar always visible
function map.update_hud_flags(player)
	player:hud_set_flags({
		minimap = true,
		minimap_radar = true
	})
end