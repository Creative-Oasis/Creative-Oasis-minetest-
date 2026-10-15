
adaptation_lib.add_mod("player", {
    formspec_inv = "list[current_player;main;0.5,3;10,4;]",
		next_line_offset_inv = 10,

    attach_player = function(player_name)
      hades_player.player_attached[player_name] = true
    end,
    deattach_player = function(player_name)
      hades_player.player_attached[player_name] = nil
    end,
    set_animation = function(player, animation, frames)
      hades_player.set_animation(player, animation, frames)
    end,
  })

