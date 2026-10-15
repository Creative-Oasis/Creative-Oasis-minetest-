
if craft_conflict_exchanger.settings.allowExchangerCrafting then
  core.register_craft {
    output = "craft_conflict_exchanger:exchanger",
    recipe = {
      {"",           "group:stone", ""},
      {"group:wood", "group:wood",  "group:stone"},
      {"",           "group:stone", "group:wood"},
    }
  }
end
