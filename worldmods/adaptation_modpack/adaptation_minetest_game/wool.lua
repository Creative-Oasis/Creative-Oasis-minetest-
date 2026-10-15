
for color_key, color_data in pairs(adaptation_lib.basic_colors) do
  adaptation_lib.add_item("wool_"..color_key, {
      name = "wool:"..color_key,
      tile = "wool_"..color_key..".png",
      lists = {"wool"},
      
      color = color_key,
    })
end

adaptation_lib.add_mod("wool", {
    name = "wool",
    prefix = "wool:",
    clear_colored_wool_recipe = function (color)
      minetest.clear_craft({
          type = "shapeless",
          --output = "wool:"..color,
          recipe = {"group:dye,color_"..color, "group:wool"},
        })
    end,
  })

