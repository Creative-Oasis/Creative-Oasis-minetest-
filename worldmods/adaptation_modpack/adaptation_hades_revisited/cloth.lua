
adaptation_lib.add_item("wool_raw", {
    name = "hades_cloth:white",
      tile = "wool_white.png",
    lists = {"wool"},
  })

for color_key, color_data in pairs(adaptation_lib.basic_colors) do
  adaptation_lib.add_item("wool_"..color_key, {
      name = "hades_cloth:"..color_key,
      tile = "wool_"..color_key..".png",
      lists = {"wool"},
      
      color = color_key,
    })
end

adaptation_lib.add_mod("wool", {
    name = "hades_cloth",
    prefix = "hades_cloth:",
    clear_colored_wool_recipe = function (color)
      minetest.clear_craft({
          type = "shapeless",
          --output = "wool:"..color,
          recipe = {"hades_dye:"..color, "group:cloth"},
        })
    end,
  })

