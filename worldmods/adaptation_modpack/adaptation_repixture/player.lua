
adaptation_lib.add_mod("player", {
    formspec_inv = "list[current_player;main;0.5,3;10,4;]",

    attach_player = function(player_name)
      rp_player.player_attached[player_name] = true
    end,
    deattach_player = function(player_name)
      rp_player.player_attached[player_name] = nil
    end,
    set_animation = function(player, animation, frames)
      rp_player.player_set_animation(player, animation, frames)
    end,
  })

