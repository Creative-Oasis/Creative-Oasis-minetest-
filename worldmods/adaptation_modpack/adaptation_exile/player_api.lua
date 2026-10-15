
adaptation_lib.add_mod("player", {
    formspec_inv = "list[current_player;main;1.5,3;8,4;]",

    attach_player = function(player_name)
      player_api.player_attached[player_name] = true
    end,
    deattach_player = function(player_name)
      player_api.player_attached[player_name] = nil
    end,
    set_animation = function(player, animation, frames)
      player_api.set_animation(player, animation, frames)
    end,
  })

