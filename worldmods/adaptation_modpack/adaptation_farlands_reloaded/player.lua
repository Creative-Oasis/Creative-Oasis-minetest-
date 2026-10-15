
adaptation_lib.add_mod("player", {
    formspec_inv = "list[current_player;main;1.5,3;8,4;]",

    attach_player = function(player_name)
      --fl_player.player_attached[player_name] = true
    end,
    deattach_player = function(player_name)
      --fl_player.player_attached[player_name] = nil
    end,
    set_animation = function(player, animation, frames)
      if fl_player.animations[animation] then
        player:set_animation(fl_player.animations[animation], frames)
      end
    end,
  })

