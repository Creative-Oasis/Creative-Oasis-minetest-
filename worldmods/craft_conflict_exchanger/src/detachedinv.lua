
local INV_SUFFIX = "_craftconflictinv"
local INPUT_LIST_NAME = "main"

function craft_conflict_exchanger.get_detached_inventory_name_for(playerName)
  return playerName..INV_SUFFIX
end

-- returns an InvRef for the confict exchanger's inventory
function craft_conflict_exchanger.get_detached_inv_for(playerName)
  local invName = craft_conflict_exchanger.get_detached_inventory_name_for(playerName)
  local invRef = core.get_inventory {
    type = "detached", name = invName,
  }
  if invRef ~= nil and invRef.type ~= "undefined" then
    return invRef
  else
    local exchangerForm = craft_conflict_exchanger.get_exchanger_respec_form()
    invRef = core.create_detached_inventory(
      invName,
      {
        on_move = function(_, _, _, _, _, _, player)
          exchangerForm:reshow(player:get_player_name())
        end,
        on_put = function(_, _, _, _, player)
          exchangerForm:reshow(player:get_player_name())
        end,
        on_take = function(_, _, _, _, player)
          exchangerForm:reshow(player:get_player_name())
        end,
      },
      playerName
    )
    invRef:set_size(INPUT_LIST_NAME, 1)
    return invRef
  end
end
