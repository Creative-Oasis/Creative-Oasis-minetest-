
if craft_conflict_exchanger.settings.allowExchangerCommand then
  core.register_chatcommand("item-exchanger", {
    description = "Gives you a single Craft Conflict Exchanger node\nAs backup if you cannot craft it (e.g. due to craft conflicts)",
    func = function(name, paarm)
      local player = core.get_player_by_name(name)
      if not player then return end
      local inv = player:get_inventory()
      local leftover = inv:add_item("main", ItemStack("craft_conflict_exchanger:exchanger"))
      if not leftover:is_empty() then
        core.item_drop(leftover, player, player:get_pos())
      end
    end
  })
end
