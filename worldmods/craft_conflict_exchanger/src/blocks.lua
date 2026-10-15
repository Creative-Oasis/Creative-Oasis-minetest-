local INPUT_LIST_NAME = "main"

local exchangerForm = craft_conflict_exchanger.get_exchanger_respec_form()

-- setup funcs

local function can_dig_exchanger(pos, player)
  if not player then return true end
  local playerName = player:get_player_name()
  return craft_conflict_exchanger.get_detached_inv_for(playerName):is_empty(INPUT_LIST_NAME)
end

local function on_inv_put_exchanger(pos, listname, index, stack, player)
  exchangerForm:reshow(player:get_player_name())
end

local function on_inv_take_exchanger(pos, listname, index, stack, player)
  exchangerForm:reshow(player:get_player_name())
end

-- registration

core.register_node("craft_conflict_exchanger:exchanger", {
  short_description = "Item Exchanger",
  description = "Item Exchanger\nExchanges items with same crafting or cooking recipes\nCan also be obtained with the '/item-exchanger' command",
  drawtype = "normal",
  groups = {
    cracky = 3, choppy = 3, oddly_breakable_by_hand = 2, pickaxey = 1, axey = 1, handy = 1,
  },
  tiles = {"item_exchanger_top_bot.png", "item_exchanger_top_bot.png", "item_exchanger_side.png"},
  drop = "craft_conflict_exchanger:exchanger",
  can_dig = can_dig_exchanger,
  on_rightclick = exchangerForm:show_on_node_rightclick(nil, false),
})
