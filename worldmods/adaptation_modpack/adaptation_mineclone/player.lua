
adaptation_lib.add_mod("player", {
    formspec_inv = 
      "list[current_player;main;0,4.5;9,3;9]"..
      mcl_formspec.get_itemslot_bg(0,4.5,9,3)..
      "list[current_player;main;0,7.74;9,1;]"..
      mcl_formspec.get_itemslot_bg(0,7.74,9,1),

    attach_player = function(player_name)
      mcl_player.player_attached[player_name] = true
    end,
    deattach_player = function(player_name)
      mcl_player.player_attached[player_name] = nil
    end,
    set_animation = function(player, animation, frames)
      mcl_player.player_set_animation(player, animation, frames)
    end,
  })

